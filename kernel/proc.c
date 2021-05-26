#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"

#include "spinlock.h"
// //task 1
// #include "file.h"


#include "proc.h"
#include "defs.h"


struct cpu cpus[NCPU];

struct proc proc[NPROC];

struct proc *initproc;

int nextpid = 1;
struct spinlock pid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);

extern char trampoline[]; // trampoline.S

// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;



//task 1
int ndx;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
  }
}

// initialize the proc table at boot time.
void
procinit(void)
{
  struct proc *p;

  initlock(&pid_lock, "nextpid");
  initlock(&wait_lock, "wait_lock");
  for(p = proc; p < &proc[NPROC]; p++) {
      initlock(&p->lock, "proc");
      p->kstack = KSTACK((int) (p - proc));
  }
}

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
  int id = r_tp();
  return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;
}

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
  push_off();
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
  pop_off();
  return p;
}

int
allocpid() {
  int pid;

  acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1;
  release(&pid_lock);

  return pid;
}

// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state == UNUSED) {
      goto found;
    } else {
      release(&p->lock);
    }
  }
  return 0;

found:
  p->pid = allocpid();
  p->state = USED;

  // Allocate a trapframe page.
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  if(p->pagetable == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&p->context, 0, sizeof(p->context));
  p->context.ra = (uint64)forkret;
  p->context.sp = p->kstack + PGSIZE;

  //task 1
  // if (p->name != "shell" && p->name != "init") {
    struct page_struct *pa_swap;
    printf("allocproc, p->pid: %d, p->files_in_swap: %d\n", p->pid, p->files_in_swap);
    for(pa_swap = p->files_in_swap; pa_swap < &p->files_in_swap[MAX_PSYC_PAGES] ; pa_swap++) {
      pa_swap->isAvailable = 1;
      // pa_swap->isUsed = 0;
      pa_swap->va = -1;
      pa_swap->offset = -1;
    }

      struct page_struct *pa_psyc;
    printf("@@@@@@allocproc, p->pid: %d, p->files_in_physicalmem: %d\n", p->pid, p->files_in_physicalmem);

    for(pa_psyc = p->files_in_physicalmem; pa_psyc < &p->files_in_physicalmem[MAX_PSYC_PAGES] ; pa_psyc++) {
      pa_psyc->isAvailable = 1;
      // pa_psyc->isUsed = 0;
      pa_psyc->va = -1;
      pa_psyc->offset = -1;
    }
    p->num_of_pages = 0;    //in the beginning there aren't any pages in process virtual memory
  // }
  //TESTING
  // if((p->pid != 0) && (p->pid != 1)){
  //   printf("In allocproc, files in phys:\n");
  // print_page_array(p->files_in_physicalmem);
  // printf("filess in swap:\n");
  // print_page_array(p->files_in_swap);
  // }


  return p;
}

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
  if(p->trapframe)
    kfree((void*)p->trapframe);
  p->trapframe = 0;
  if(p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->state = UNUSED;
}

// Create a user page table for a given process,
// with no user memory, but with trampoline pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
  if(pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    return 0;
  }

  // map the trapframe just below TRAMPOLINE, for trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

// a user program that calls exec("/init")
// od -t xC initcode
uchar initcode[] = {
  0x17, 0x05, 0x00, 0x00, 0x13, 0x05, 0x45, 0x02,
  0x97, 0x05, 0x00, 0x00, 0x93, 0x85, 0x35, 0x02,
  0x93, 0x08, 0x70, 0x00, 0x73, 0x00, 0x00, 0x00,
  0x93, 0x08, 0x20, 0x00, 0x73, 0x00, 0x00, 0x00,
  0xef, 0xf0, 0x9f, 0xff, 0x2f, 0x69, 0x6e, 0x69,
  0x74, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00
};

// Set up first user process.
void
userinit(void)
{
  struct proc *p;

  p = allocproc();
  initproc = p;

  // allocate one user page and copy init's instructions
  // and data into it.
  uvminit(p->pagetable, initcode, sizeof(initcode));
  p->sz = PGSIZE;

  // prepare for the very first "return" from kernel to user.
  p->trapframe->epc = 0;      // user program counter
  p->trapframe->sp = PGSIZE;  // user stack pointer

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;

  release(&p->lock);
}

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *p = myproc();

  sz = p->sz;
  if(n > 0){
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
      return -1;
    }
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  return 0;
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));

  pid = np->pid;

  release(&np->lock);

  //if this isn't init or shell, create swap file
  if(np->pid != 0 && np->pid != 1){
    createSwapFile(np);
    //copy parent's arrays of memory arrangement
    copy_memory_arrays(p, np);
    //if parent has swap file, copy its content
    if(p->swapFile){
      copy_file(np, p);
    }
  }




  acquire(&wait_lock);
  np->parent = p;
  release(&wait_lock);

  acquire(&np->lock);
  np->state = RUNNABLE;
  release(&np->lock);

  return pid;
}

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void
reparent(struct proc *p)
{
  struct proc *pp;

  for(pp = proc; pp < &proc[NPROC]; pp++){
    if(pp->parent == p){
      pp->parent = initproc;
      wakeup(initproc);
    }
  }
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void
exit(int status)
{
  struct proc *p = myproc();

  if(p == initproc)
    panic("init exiting");

  // Close all open files.
  for(int fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd]){
      struct file *f = p->ofile[fd];
      fileclose(f);
      p->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(p->cwd);
  end_op();
  p->cwd = 0;

  acquire(&wait_lock);

  // Give any children to init.
  reparent(p);

  // Parent might be sleeping in wait().
  wakeup(p->parent);

  acquire(&p->lock);

  p->xstate = status;
  p->state = ZOMBIE;

  release(&wait_lock);

  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(uint64 addr)
{
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(np = proc; np < &proc[NPROC]; np++){
      if(np->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if(np->state == ZOMBIE){
          // Found one.
          pid = np->pid;
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
                                  sizeof(np->xstate)) < 0) {
            release(&np->lock);
            release(&wait_lock);
            return -1;
          }
          freeproc(np);
          release(&np->lock);
          release(&wait_lock);
          return pid;
        }
        release(&np->lock);
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || p->killed){
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.
//sss
void
scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();

  c->proc = 0;
  for(;;){
    // Avoid deadlock by ensuring that devices can interrupt.
    intr_on();

    for(p = proc; p < &proc[NPROC]; p++) {
      acquire(&p->lock);
      if(p->state == RUNNABLE) {
        // Switch to chosen process.  It is the process's job
        // to release its lock and then reacquire it
        // before jumping back to us.
        p->state = RUNNING;
        c->proc = p;
        swtch(&c->context, &p->context);
        // Process is done running for now.
        // It should have changed its p->state before coming back.
        c->proc = 0;
      }
      release(&p->lock);
    }

  }
}

// Switch to scheduler.  Must hold only p->lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&p->lock))
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(intr_get())
    panic("sched interruptible");

  intena = mycpu()->intena;
  swtch(&p->context, &mycpu()->context);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  struct proc *p = myproc();
  acquire(&p->lock);
  p->state = RUNNABLE;
  sched();
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);

  if (first) {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();

  // Must acquire p->lock in order to
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
  release(lk);

  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  release(&p->lock);
  acquire(lk);
}

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
        p->state = RUNNABLE;
      }
      release(&p->lock);
    }
  }
}

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){
      p->killed = 1;
      if(p->state == SLEEPING){
        // Wake process from sleep().
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
  }
  return -1;
}

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();
  if(user_dst){
    return copyout(p->pagetable, dst, src, len);
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();
  if(user_src){
    return copyin(p->pagetable, dst, src, len);
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    printf("%d %s %s", p->pid, state, p->name);
    printf("\n");
  }
}

 ///////////////////////// - swap functions - /////////////////////////

  //returns a free index in physical memory
 int find_free_index(struct page_struct* pagearr) {
  //  for (int i = 0; i < MAX_PSYC_PAGES; i++) {
  //    printf("pid: %d, i: %d, pagearr[i].isAvailable: %d\n",myproc()->pid, i, pagearr[i].isAvailable);
  //    if (pagearr[i].isAvailable) {
  //     //  printf(" pagearr[i].isAvailable: %d\n", )
  //      return i;
  //    }
  //  }
  struct page_struct *arr;
  int i = 0;
  for(arr = pagearr; arr < &pagearr[MAX_PSYC_PAGES]; arr++){
    // printf("pid: %d, i: %d, pagearr[i].isAvailable: %d\n",myproc()->pid, i, pagearr[i].isAvailable);
    if(arr->isAvailable){
      return i;
    }
    i++;
  }
   return -1; //in case there no space
 }

 //return 0 on success, return -1 on failure
 int add_page_to_phys(struct proc* p, uint64* page, uint64 va) {
  //  struct proc *p = myproc();
   int index = find_free_index(p->files_in_physicalmem);
   if (index == -1) {
    free_page_from_phys(p);
    index = find_free_index(p->files_in_physicalmem);
     if (index == -1)
      return -1; //cannot add page
   } else {
     p->files_in_physicalmem[index].isAvailable = 0;
     p->files_in_physicalmem[index].page = page;
     p->files_in_physicalmem[index].va = va;
    //  printf("page index: %d , va in add: %d\n",index, va);
     p->files_in_physicalmem[index].offset = -1;   //offset is a field for files in swap_file only
    p->num_of_pages++;
    p->num_of_pages_in_phys++;
   }
   return 0;
 }

//removes page from the array
 int remove_page_from_phys(struct proc* p, int index) {
  //  struct proc *p = myproc();
    p->files_in_physicalmem[index].isAvailable = 1;
    p->files_in_physicalmem[index].page = 0;
    p->files_in_physicalmem[index].va = -1;
    p->files_in_physicalmem[index].offset = -1;
    return 0;
 }

 int add_page_to_swapfile_array(struct proc* p, uint64* page, uint64 va, int offset) {
  //  struct proc *p = myproc();
   int index = find_free_index(p->files_in_swap);
   if (index == -1) {
     return -1; //cannot add page
   } else {
     p->files_in_swap[index].isAvailable = 0;
     p->files_in_swap[index].page = page;
     p->files_in_swap[index].va = va;
     p->files_in_swap[index].offset = offset;
   }
   return 0;
 }

 int delete_page_from_file_arr(struct proc* p, int index) {
  //  struct proc *p = myproc();
    p->files_in_swap[index].isAvailable = 1;
    p->files_in_swap[index].page = 0;
    p->files_in_swap[index].va = -1;
    p->files_in_swap[index].offset = -1;
    return 0;
 }
//TODO
 int find_page_to_swap() {
   struct proc* p = myproc();
   for (int i=0; i<MAX_PSYC_PAGES; i++) {
     if (p->files_in_physicalmem[i].isAvailable) {
       return i;
     }
   }
   return 0;
 }

 int free_page_from_phys(struct proc* p) {
   int index = find_page_to_swap();
   if (index == -1) {
     printf("error in swap\n");
     return -1;
   }
    // struct proc* p = myproc();
    pte_t* page_to_swap = p->files_in_physicalmem[index].page;
    swap_to_swapFile(p, page_to_swap, index);

    //find physical address
    //#define PTE_ADDR(pte)   ((uint)(pte) & ~0xFFF)
    //#define P2V(a) (((void *) (a)) + KERNBASE)
    //#define KERNBASE 0x80000000
    // uint pa = PTE_ADDR(*swap_page); //physical address
    // if(pa==0){panic("kfree");}
    // char* v = P2V(pa);
    // kfree(v); //frees the physical page

    pte_t* pte = walk(p->pagetable ,p->files_in_physicalmem[index].va, 0);
    char *pa = (char *)PTE2PA(*pte);
    kfree(pa);
    sfence_vma();

   return 0;
 }


//find index in files_in_physicalmem array. returns -1 if index not found
// int find_ndx_of_pg_in_physmem_arr(pte_t *page){
//   int index = 0;
//   struct proc *p = myproc();
//   struct page_struct *ps;
//   for(ps = p->files_in_physicalmem; ps < &p->files_in_physicalmem[MAX_PSYC_PAGES]; ps++){
//     if(ps->page == page){
//       return index;
//     }
//     index++;
//   }
//   //if we got here, page wasn't found
//   return -1;
// }

int find_index_file_arr(uint64 address) {
  // uint64 va = PGROUNDDOWN(address);
  for (int i=0; i<MAX_PSYC_PAGES; i++) {
    if (myproc()->files_in_swap[i].offset == address) {
      return i;
    }
  }
  return -1;
}


// int find_free_offset() {

// }

//swap given page from physical memory to swapFile
int swap_to_swapFile(struct proc* p, pte_t *page, int ndx) {
  // struct proc *p = myproc();
  //find the page's index in the files_in_physicalmem array
  // int ndx = find_ndx_of_pg_in_physmem_arr(page);
  //find free insex in files_in_swap array
  // printf("ndx: %d\n", ndx);
  ndx = (ndx + 1)%15;
  int file_index = find_free_index(p->files_in_swap);
  uint offset = file_index*PGSIZE;
  //update swapFile's offset according to the offset we found (so filewrite will write to the right place)
  // p->swapFile->off = offset;
  //find virtual address and write the page to the swapFile
  //TODO make sure va is updated and correct

  uint64 va = p->files_in_physicalmem[ndx].va;

  //TODO make sure it's correct to write physical memory
  char *pa = (char *)(PTE2PA(*page));
  //TODO check that castingis ok
  writeToSwapFile(p, (char *)pa, offset, PGSIZE);

  add_page_to_swapfile_array(p, page, va, offset);
  remove_page_from_phys(p, ndx);

  //turn off valid flag (this page is not on physical memory anymore) TODO - check we understood valid flag correctly
  (*page) &= ~PTE_V;
  //set the flag indicating that the page was laged out to secondary storage
  (*page) |= PTE_PG;
  return 1;
}

int copy_file(struct proc* dest, struct proc* source) {
  //TODO maybe need to add file size
  char* buf = kalloc();
  for(int i=0; i<MAX_PSYC_PAGES*PGSIZE; i = i+PGSIZE) {
    readFromSwapFile(source, buf, i, PGSIZE);
    writeToSwapFile(dest, buf, i, PGSIZE);
  }
  kfree(buf);
  return 0;
}


//swap a single page into ram
int swap_to_memory(struct proc* p, uint64 address) {
  //make room for the page in memory using kalloc
  char* buff;
  if ((buff = kalloc()) == 0) {
    panic("kalloc failed");
  }
  uint64 va = PGROUNDDOWN(address);
  printf("va: %d", va);
  //find a free index in main memory array
  int mem_ind = find_free_index(p->files_in_physicalmem);
  //if there isn't a free index, make one
  if (mem_ind == -1) {
    free_page_from_phys(p);
    if((mem_ind = find_free_index(p->files_in_physicalmem)) == -1){
      panic("index in mainmem array not found even though one was just freed\n");
    }
  }

  pte_t* pte = walk(p->pagetable, va, 0);

  memset(buff, 0, PGSIZE);
	sfence_vma();

	*pte |= PTE_V | PTE_W | PTE_U;
	*pte &= ~PTE_PG;
	*pte |= *buff;

  int swap_ind = find_index_file_arr(va);
  //if index is -1, according to swap_file_array the file isn't in swapfile
  if (swap_ind == -1) {
    panic("index in file is -1");
  }

  //offset in swap file
  int offset = p->files_in_swap[swap_ind].offset;
  if (offset == -1) {
    panic("offset is -1");
  }

  readFromSwapFile(p, buff, offset, PGSIZE);
  // memmove(buff, p->buff, PGSIZE);
  if (mappages(p->pagetable, va, PGSIZE, (uint64)buff, PTE_W | PTE_X | PTE_R | PTE_U) != 0)
      {
        kfree(buff);
        panic("PF_handler: mappages has failed");
      }

  p->files_in_physicalmem[mem_ind].page = pte;
  p->files_in_physicalmem[mem_ind].isAvailable = 0;
  p->files_in_physicalmem[mem_ind].va =  p->files_in_swap[swap_ind].va;
  p->num_of_pages_in_phys++;

  p->files_in_swap[swap_ind].offset = -1;
  p->files_in_swap[swap_ind].isAvailable = 1;
  return 0;
  // int swap_ind = find_index_file_arr(address);
  // //if index is -1, according to swap_file_array the file isn't in swapfile
  // if (swap_ind == -1) {
  //   panic("index in file is -1");
  // }
  // //offset in swap file
  // int offset = p->files_in_swap[swap_ind].offset;
  // if (offset == -1) {
  //   panic("offset is -1");
  // }
  // //find a free index in main memory array
  // int mem_ind = find_free_index(p->files_in_physicalmem);
  // //if there isn't a free index, make one
  // if (mem_ind == -1) {
  //   free_page_from_phys(p);
  //   if((mem_ind = find_free_index(p->files_in_physicalmem)) == -1){
  //     panic("index in mainmem array not found even though one was just freed\n");
  //   }
  // }
  // //make room for the page in memory using kalloc
  // char* buff;
  // if ((buff = kalloc()) == 0) {
  //   panic("kalloc failed");
  // }
  // //copy the content of the page, from swapfile to the page we allocated in main memory
  // readFromSwapFile(p, buff, offset, PGSIZE);
  // //prepare the pte for this page
  // *page = PA2PTE((uint64)buff) | ((PTE_FLAGS(*page)& ~PTE_PG) | PTE_V);
  // // pte_to_insert = pte_to_insert | ((PTE_FLAGS(*pte_to_insert)& ~PTE_PG) | PTE_V);
  // p->files_in_physicalmem[mem_ind].page = page;
  // p->files_in_physicalmem[mem_ind].isAvailable = 0;
  // p->files_in_physicalmem[mem_ind].va =  p->files_in_swap[swap_ind].va;
  // p->num_of_pages_in_phys++;

  // p->files_in_swap[swap_ind].offset = -1;
  // p->files_in_swap[swap_ind].isAvailable = 1;

  // return 0;




  // char *pa = (char *)(PTE2PA(*page));
  // readFromSwapFile(p, (char*) pa, offset, PGSIZE);
  // p->files_in_swap[swap_ind].offset = -1;
  // p->files_in_swap[swap_ind].isAvailable = 1;
  // (*page) |= PTE_PG;
  // (*page) &= ~PTE_PG;
  // p->files_in_physicalmem[mem_ind].page = page;
  // p->files_in_physicalmem[mem_ind].isAvailable = 0;
  // p->files_in_physicalmem[mem_ind].va =  p->files_in_swap[swap_ind].va;
  // p->num_of_pages_in_phys++;
  // mem_ind = find_free_index(p->files_in_physicalmem);
  // return 0;
}

//for cases when page isn't in swap file
void hanle_page_fault(struct proc* p) {
  // struct proc* p = myproc();
  printf("files in memory:\n");
  print_page_array(p, p->files_in_physicalmem);
  printf("files in swap:\n");
  print_page_array(p, p->files_in_swap);

  //determine the faulting address
  uint64 va = r_stval();
  printf("fault address: %d\n", va);
  // uint64 va = PGROUNDDOWN(fault_address); //find virtual address
  pte_t* pte = walk(p->pagetable, va, 0); //identify the page
  if (*pte & PTE_PG) {
    swap_to_memory(p, va);
  } else { //In case that it is segmantation fault
    printf("usertrap1(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    p->killed = 1;
  }
}

void print_page_array(struct proc* p ,struct page_struct* pagearr) {
  for (int i =0; i<MAX_PSYC_PAGES; i++) {
    struct page_struct curr = pagearr[i];
    printf("pid: %d, index: %d, page: %d, isAvailable: %d, va: %d, offset: %d\n",
    p->pid, i, curr.page, curr.isAvailable, curr.va, curr.offset);
  }
}