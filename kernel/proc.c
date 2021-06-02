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
  #ifndef NONE
  if (p->pid > 2){
    release(&p->lock);
    if(createSwapFile(p) < 0)
      panic("allocproc swapfile creation failed\n");
    acquire(&p->lock);

  }
  init_meta_data(p);
  #endif
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
  #ifndef NONE
  init_meta_data(p); //TODO not sure
  p->num_of_pages = 0;
  #endif
  // printf("end freeproc\n");
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
    printf("fork allocproc failed\n");
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

  //TODO diff in place of ifndef
  #ifndef NONE
  //if this isn't init or shell take care of paging structs
  if(np->pid > 2){
    np->num_of_pages = p->num_of_pages;
    np->num_of_pages_in_phys = p->num_of_pages_in_phys;
    // #ifndef NONE
    #ifdef SCFIFO
      np->index_of_head_p = p->index_of_head_p;
      np->index_of_tail_p = p->index_of_tail_p;
    #endif
    for (int i = 0; i<MAX_PSYC_PAGES; i++) {
      memmove((void *)&np->files_in_physicalmem[i], (void *)&p->files_in_physicalmem[i], sizeof(struct page_struct));
      // memmove((void *)&np->files_in_swap[i], (void *)&p->files_in_swap[i], sizeof(struct page_struct));
    }
    for (int i = 0; i<MAX_SWAP_PAGES; i++) {
      memmove((void *)&np->files_in_swap[i], (void *)&p->files_in_swap[i], sizeof(struct page_struct));
    }
    //if parent has swap file, copy its content
    if(p->swapFile){
      copy_file(np, p);
    }
  }
  #endif

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

  if (p->pid > 2) {
	  removeSwapFile(p);
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
        if (p->pid > 2) {
          #ifdef NFUA
            update_counter_NFUA(p);
          #endif
          #ifdef LAPA
            update_counter_LAPA(p);
          #endif
        }

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
  // printf("yield pid %d\n", myproc()->pid );
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
// #ifndef NONE


//returns a free index in page_struct array. which_arr==0 if it's physical memory, which_arr==1 if swapfile
 int find_free_index(struct page_struct* pagearr, int which_arr) {
  struct page_struct *arr;
  int i = 0;
  if(which_arr == 0){
    for(arr = pagearr; arr < &pagearr[MAX_PSYC_PAGES]; arr++){
      if(arr->isAvailable){
        return i;
      }
      i++;
    }
  }
  else {
    for(arr = pagearr; arr < &pagearr[MAX_SWAP_PAGES]; arr++){
      if(arr->isAvailable){
        return i;
      }
      i++;
    }
  }
  return -1; //in case there no space
 }

 void init_meta_data(struct proc* p) {
  p->num_of_pages = 0;
  p->num_of_pages_in_phys = 0;
  struct page_struct *pa_swap;
  // printf("allocproc, p->pid: %d, p->files_in_swap: %d\n", p->pid, p->files_in_swap);
  for(pa_swap = p->files_in_swap; pa_swap < &p->files_in_swap[MAX_SWAP_PAGES] ; pa_swap++) {
    pa_swap->pagetable = p->pagetable;
    pa_swap->isAvailable = 1;

    pa_swap->va = -1;
    pa_swap->offset = -1;
    #ifdef NFUA
     pa_swap->counter_NFUA = 0;
    #endif
    #ifdef SCFIFO
      pa_swap->index_of_prev_p = -1;
      pa_swap->index_of_next_p = -1;
    #endif
  }

  struct page_struct *pa_psyc;

  for(pa_psyc = p->files_in_physicalmem; pa_psyc < &p->files_in_physicalmem[MAX_PSYC_PAGES] ; pa_psyc++) {
    pa_psyc->pagetable = p->pagetable;
    pa_psyc->isAvailable = 1;
    pa_psyc->va = -1;
    pa_psyc->offset = -1;
    #ifdef SCFIFO
      pa_swap->index_of_prev_p = -1;
      pa_swap->index_of_next_p = -1;
    #endif
  }

  #ifdef SCFIFO
    p->index_of_head_p = -1;  //no pages in ram so no head
    p->index_of_tail_p = -1;  //same for tail
  #endif
}

 /*
  Adds a page_struct (for the given va) to ram array
 */
int add_page_to_phys(struct proc* p, pagetable_t pagetable, uint64 va) {

  int index = find_free_index(p->files_in_physicalmem, 0);
  // printf("adding page to ram and printing array\n");
  // print_page_array(p, p->files_in_physicalmem);

  if (index == -1){
    panic("no free index in ram\n");
  }

  p->files_in_physicalmem[index].isAvailable = 0;
  p->files_in_physicalmem[index].pagetable = pagetable;
  p->files_in_physicalmem[index].page = walk(pagetable, va, 0);
  p->files_in_physicalmem[index].va = va;
  p->files_in_physicalmem[index].offset = -1;   //offset is a field for files in swap_file only

  #ifdef NFUA
    p->files_in_physicalmem[index].counter_NFUA = 0;
  #endif
  #ifdef LAPA
    p->files_in_physicalmem[index].counter_LAPA = -1;
  #endif

  #ifdef SCFIFO
    //if this is the first page added to ram aray, initialize values accordingly
    if(p->index_of_head_p == -1){
      p->index_of_head_p = index;
      p->index_of_tail_p = index;
      printf("first head initialized. index: %d. va/PGSIZE: %d\n", index, va/PGSIZE);
      p->files_in_physicalmem[index].index_of_prev_p = index;
      p->files_in_physicalmem[index].index_of_next_p = index;
    }
    else {
      //head's previous prev is curr's new prev
      p->files_in_physicalmem[index].index_of_prev_p = p->files_in_physicalmem[p->index_of_head_p].index_of_prev_p;
      //curr is last. curr's next is head
      p->files_in_physicalmem[index].index_of_next_p = p->index_of_head_p;
      //head's prev is curr
      p->files_in_physicalmem[p->index_of_head_p].index_of_prev_p = index;
      //update prev's index_of_next to be curr (instead of head)
      p->files_in_physicalmem[p->files_in_physicalmem[index].index_of_prev_p].index_of_next_p = index;
      //newly added page is the tail
      p->index_of_tail_p = index;
    }
  #endif

  p->num_of_pages++;
  p->num_of_pages_in_phys++;
  return 0;
}


int find_index_file_arr(struct proc* p, uint64 address) {
  // uint64 va = PGROUNDDOWN(address);
  for (int i=0; i<MAX_SWAP_PAGES; i++) {
    if ((p->files_in_swap[i].isAvailable == 0) && p->files_in_swap[i].va == address) {
      return i;
    }
  }
  return -1;
}

/*
  Inserts a page_struct to ram array.
  Before insertion, finds a page in ram to swap into swapfile.
*/
int swap_to_swapFile(struct proc* p, pagetable_t pagetable) {
  int mem_ind = calc_ndx_for_ramarr_removal(p);  //index of page to remove from ram array
  // printmem();
  int swap_ind = find_free_index(p->files_in_swap, 1);
  //for scfifo, update memory arrays' prevs and nexts, and ram array's head
  #ifdef SCFIFO
    //update ram array
    //curr's next's index_of_prev should be updated to curr's prev
    p->files_in_physicalmem[p->files_in_physicalmem[mem_ind].index_of_next_p].index_of_prev_p = p->files_in_physicalmem[mem_ind].index_of_prev_p;
    //curr's prev's next dhould be updated to curr's next
    p->files_in_physicalmem[p->files_in_physicalmem[mem_ind].index_of_prev_p].index_of_next_p = p->files_in_physicalmem[mem_ind].index_of_next_p;
    //if the page removed was tail, update new tail
    if(p->index_of_tail_p == mem_ind){
      p->index_of_tail_p = p->files_in_physicalmem[mem_ind].index_of_prev_p;
    }
    //if the page removed was the head, update new head
    if(p->index_of_head_p == mem_ind){
      //if it's the only one in the array, head should now be -1
      if(p->index_of_head_p == p->files_in_physicalmem[mem_ind].index_of_next_p){
        p->index_of_head_p = -1;
      }
      //else, head will be the next page
      else {
        p->index_of_head_p = p->files_in_physicalmem[mem_ind].index_of_next_p;
      }
      p->files_in_physicalmem[mem_ind].index_of_prev_p = -1;
      p->files_in_physicalmem[mem_ind].index_of_next_p = -1;
    }
    //take care of fields in swap arr
    p->files_in_swap[swap_ind].index_of_prev_p = -1;
    p->files_in_swap[swap_ind].index_of_next_p = -1;
  #endif

  //insert page in mem_ind to swapfile
  // pagetable_t pagetable_to_swap_file = p->files_in_physicalmem[mem_ind].pagetable;
  pagetable_t pagetable_to_swap_file = pagetable;

  uint64 va_to_swap_file = p->files_in_physicalmem[mem_ind].va;

  //
  pte_t *pte2 = walk(pagetable_to_swap_file, va_to_swap_file, 0);
  *pte2 |= PTE_U;
  //

  uint64 pa = walkaddr(pagetable_to_swap_file, va_to_swap_file);
  int offset = swap_ind*PGSIZE; //find offset we want to insert to
  if (writeToSwapFile(p, (char *)pa, offset, PGSIZE) == -1)
    panic("an error occurred while writing to swap file");

  //update swap_arr with the new file
  p->files_in_swap[swap_ind].pagetable = pagetable_to_swap_file;
  p->files_in_swap[swap_ind].va = va_to_swap_file;
  p->files_in_swap[swap_ind].isAvailable = 0;
  p->files_in_swap[swap_ind].offset = offset;
  p->files_in_swap[swap_ind].page = p->files_in_physicalmem[mem_ind].page;

  //kfree selected file from memory
  pte_t* pte = walk(pagetable, p->files_in_physicalmem[mem_ind].va, 0);
  char *pa_tofree = (char *)PTE2PA(*pte);
  kfree(pa_tofree);

  //update pte flags
  //turn off valid flag (this page is not on physical memory anymore)
  (*pte) &= ~PTE_V;
  //set the flag indicating that the page was paged out to secondary storage
  (*pte) |= PTE_PG;

  sfence_vma();

  //update mem_arr
  p->files_in_physicalmem[mem_ind].isAvailable = 1;

  #ifdef NFUA
  p->files_in_physicalmem[mem_ind].counter_NFUA = 0;
  #endif
  #ifdef LAPA
  p->files_in_physicalmem[mem_ind].counter_LAPA = -1;
  #endif

  p->num_of_pages_in_phys--;
  return 0;
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


int insert_from_swap_to_ram(struct proc* p, char* buff ,uint64 va) {

    if(mappages(p->pagetable, va, PGSIZE, (uint64)buff,  (PTE_W | PTE_U | PTE_X | PTE_R)) == -1)
      printf("walk() couldn't allocate a needed page-table page\n");
    int swap_ind = find_index_file_arr(p, va);
    //if index is -1, according to swap_file_array the file isn't in swapfile
    if (swap_ind == -1) {
      panic("index in file is -1");
    }
    int offset = p->files_in_swap[swap_ind].offset;
    if (offset == -1) {
      panic("offset is -1");
    }
    readFromSwapFile(p, buff, offset, PGSIZE);

    //copy swap_arr[index] to mem_arr[index] and change swap_arr[index] to available
    int mem_ind = find_free_index(p->files_in_physicalmem, 0);
    p->files_in_physicalmem[mem_ind].pagetable = p->files_in_swap[swap_ind].pagetable;
    p->files_in_physicalmem[mem_ind].page = p->files_in_swap[swap_ind].page;
    p->files_in_physicalmem[mem_ind].va = p->files_in_swap[swap_ind].va;
    p->files_in_physicalmem[mem_ind].offset = -1;
    p->files_in_physicalmem[mem_ind].isAvailable = 0;
    p->num_of_pages_in_phys++;

    p->files_in_swap[swap_ind].isAvailable = 1;

    //need to maintain counter fiels value
    #ifdef NFUA
      p->files_in_physicalmem[mem_ind].counter_NFUA = 0;
    #endif
    #ifdef LAPA
      p->files_in_physicalmem[mem_ind].counter_LAPA = -1; //0xFFFFFF
    #endif
    //in scfifo we need to maintain the field values
    #ifdef SCFIFO
      //head's previous prev is curr's new prev
      p->files_in_physicalmem[mem_ind].index_of_prev_p = p->files_in_physicalmem[p->index_of_head_p].index_of_prev_p;
      //curr is last. curr's next is head
      p->files_in_physicalmem[mem_ind].index_of_next_p = p->index_of_head_p;
      //head's prev is curr
      p->files_in_physicalmem[p->index_of_head_p].index_of_prev_p = mem_ind;
      //update prev's index_of_next to be curr (instead of head)
      p->files_in_physicalmem[p->files_in_physicalmem[mem_ind].index_of_prev_p].index_of_next_p = mem_ind;
    #endif
    return 0;
  }


//swap a single page into ram
int swap_to_memory(struct proc* p, uint64 address) {
  uint64 va = PGROUNDDOWN(address);
  //make room for the page in memory using kalloc
  char* buff;
  if ((buff = kalloc()) == 0) {
    panic("kalloc failed");
  }

  if (p->num_of_pages_in_phys < MAX_PSYC_PAGES) {
    insert_from_swap_to_ram(p, buff, va);
    uint64 pa = walkaddr(p->pagetable, va);
    memmove((void*)pa, buff, PGSIZE); //copy page to va TODO check im not sure
  } else {
    swap_to_swapFile(p, p->pagetable);      //if there's no available place in ram, make some
    insert_from_swap_to_ram(p, buff, va); //move from swapfile the page we wanted to insert to ram
    // uint64 pa = walkaddr(p->pagetable, va);
    pte_t *pte = walk(p->pagetable, va, 0);
    uint64 pa = PTE2PA(*pte);
    memmove((void*)pa, buff, PGSIZE); //copy page to va TODO check im not sure
  }
  return 0;
}


/*
  page fault caused by instruction OR read OR write
*/
void hanle_page_fault(struct proc* p, uint64 va) {

  //determine the faulting address
  pte_t* pte = walk(p->pagetable, va, 0); //identify the page
  //if page is in swapfile, put it in ram
  if (*pte & PTE_PG) {
    swap_to_memory(p, va);
  } else { //In case that it is segmantation fault
    printf("usertrap1(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    p->killed = 1;
  }
}
// #ifdef LAPA
//ppp
void print_page_array(struct proc* p ,struct page_struct* pagearr) {
  for (int i =0; i<MAX_PSYC_PAGES; i++) {
    struct page_struct curr = pagearr[i];
    printf("pid: %d, index: %d, isAvailable: %d, va: %d, offset: %d, counter_NFUA:  \n",
    p->pid, i, curr.isAvailable, curr.va/PGSIZE, curr.offset);
  }
}
// #endif


int calc_ndx_for_ramarr_removal(struct proc *p){
//case regular - round robin
  int ndx = -1;
  #ifdef NFUA
    ndx = calc_ndx_NFUA(p);
  #endif
  #ifdef LAPA
    ndx = calc_ndx_LAPA(p);
  #endif
  #ifdef SCFIFO
    ndx = calc_ndx_for_scfifo(p);
    if(ndx == -1){
      panic("scfifo ndx wasn't found");
    }
  #endif

  return ndx;
}
#ifdef NFUA
int calc_ndx_NFUA(struct proc *p){
  int selected = -1;
  uint curr_counter = -1;
  uint lowest = -1; //biggest number

  for (int i = 0; i < MAX_PSYC_PAGES; i++) {
    struct page_struct curr_page = p->files_in_physicalmem[i];
    if (curr_page.isAvailable == 0) {
      curr_counter = curr_page.counter_NFUA;
      if (curr_counter < lowest) {
        lowest = curr_counter;
        selected = i;
      }
    }
  }
  return selected;
}
#endif
//counts the number og 1 bit's
#ifdef LAPA
int calc_ones(uint num) {
  int ret = 0;
  while (num) {
    if (num%2 != 0) {
      ret++;
    }
    num = num/2;
  }
  return ret;
}
#endif

#ifdef LAPA
int calc_ndx_LAPA(struct proc *p){

  int selected = -1;
  uint curr_index = -1;
  uint lowest = -1;
  for (int i = 0; i < MAX_PSYC_PAGES; i++) {
    struct page_struct curr_page = p->files_in_physicalmem[i];
    if (curr_page.isAvailable == 0) {
      curr_index = calc_ones(curr_page.counter_LAPA);
      if (curr_index < lowest) {
        lowest = curr_index;
        selected = i;
      }
      if (curr_index == lowest && curr_page.counter_LAPA < p->files_in_physicalmem[selected].counter_LAPA) {
        lowest = curr_index;
        selected = i;
      }
    }
  }
  return selected;
}
#endif

#ifdef SCFIFO
int calc_ndx_for_scfifo(struct proc *p){
  struct page_struct *ram_pages = p->files_in_physicalmem;
  int toReturn = -1;
  int head_ndx = p->index_of_head_p;
  int curr_ndx = p->index_of_head_p;
  struct page_struct *curr_page;
  int found = 0;
  while(found != 1){
    curr_page = &ram_pages[curr_ndx];
    //if the page was accessed, give it a second chance
    if(*(curr_page->page) & PTE_A){
      printf("page %d was accessed\n", curr_ndx);
      //clear bit
      *(curr_page->page) &= ~PTE_A;
      curr_ndx = curr_page->index_of_next_p;
      //move to end of queue
      //my prev's next is my next

      //tail's next should be me

      //I'm the new tail

      //my next is head

    }
    else {
      found = 1;
      toReturn = curr_ndx;
    }
    //the oldest page that wasn't accessed should be removed
    //if we went through all pages, finish loop
    if (curr_ndx == head_ndx){
      found = 1;
      toReturn = head_ndx;
    }
  }
  return toReturn;
}
#endif
// int counter = 0;
#ifdef NFUA
void update_counter_NFUA(struct proc* p) {
  // printf("-----------------------------------------------------------begin update_counter_NFUA\n");

  for (int i = 0; i < MAX_PSYC_PAGES; i++) {
    struct page_struct curr_page = p->files_in_physicalmem[i];
    // pte_t* pte = curr_page.page;
    if (curr_page.isAvailable == 0) {
      pte_t* pte = walk(p->pagetable, curr_page.va, 0);
      // printf("before shift\n");
      p->files_in_physicalmem[i].counter_NFUA >>=1;
      // counter++;
      // printf("counter: %d \n", counter);
      if(*pte & PTE_A) {
        p->files_in_physicalmem[i].counter_NFUA |= 0x80000000;
        // printf("curr_page.counter_NFUA %x, %d, index: %d\n", curr_page.counter_NFUA, curr_page.counter_NFUA, i);
        *pte &= ~PTE_A;
        // p->files_in_physicalmem[i].page = pte;
        // curr_page.page = pte;
        // p->files_in_physicalmem[i] = curr_page;

      }
      // p->files_in_physicalmem[i].counter_NFUA = curr_page.counter_NFUA;

    }
  }
}
#endif

#ifdef LAPA
void update_counter_LAPA(struct proc* p) {
    // printf("-----------------------------------------------------------begin update_counter_NFUA\n");

  for (int i = 0; i < MAX_PSYC_PAGES; i++) {
    struct page_struct curr_page = p->files_in_physicalmem[i];
    // pte_t* pte = curr_page.page;
    if (curr_page.isAvailable == 0) {
      pte_t* pte = walk(p->pagetable, curr_page.va, 0);
      // printf("before shift\n");
      p->files_in_physicalmem[i].counter_LAPA >>=1;
      // counter++;
      // printf("counter: %d \n", counter);
      if(*pte & PTE_A) {
        p->files_in_physicalmem[i].counter_LAPA |= 0x80000000;
        // printf("curr_page.counter_NFUA %x, %d, index: %d\n", curr_page.counter_NFUA, curr_page.counter_NFUA, i);
        *pte &= ~PTE_A;
        // p->files_in_physicalmem[i].page = pte;
        // curr_page.page = pte;
        // p->files_in_physicalmem[i] = curr_page;

      }
      // p->files_in_physicalmem[i].counter_NFUA = curr_page.counter_NFUA;

    }
  }
}
#endif

// #endif

int printmem(void){
  struct proc *p = myproc();
  if(p->pid > 2){
    printf("printmem, files in ram array:\n");
    print_page_array(p, p->files_in_physicalmem);
    printf("printmem, files in swap array:\n");
    print_page_array(p, p->files_in_swap);
  }
  else{
    printf("pid < 2\n");
  }
  return 1;
}