#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "elf.h"

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
  printf("hello from exec! path: %s\n", path);
  char *s, *last;
  int i, off;
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
  //task 2
  //create backup of ram and swapfile arrays
  //and clear the pages in arrays (we want theme cleared because the child process
  //doing exec doesn't need the memory from daddy)
  #ifndef NONE
  struct page_struct old_ram[MAX_PSYC_PAGES];
  struct page_struct old_swap[MAX_SWAP_PAGES];
  if (p->pid > 2){
    for(int i=0; i<MAX_PSYC_PAGES; i++){
      memmove((void *)&old_ram[i], (void *)&p->files_in_physicalmem[i], sizeof(struct page_struct));
      // memmove((void *)&old_swap[i], (void *)&p->files_in_swap[i], sizeof(struct page_struct));

      p->files_in_physicalmem[i].isAvailable = 1;
      // p->files_in_physicalmem[i].va = -1;
      // p->files_in_swap[i].isAvailable = 1;
      // p->files_in_swap[i].va = -1;
    }
    for(int i=0; i<MAX_SWAP_PAGES; i++){
      memmove((void *)&old_swap[i], (void *)&p->files_in_swap[i], sizeof(struct page_struct));
      p->files_in_swap[i].isAvailable = 1;
    }
  }
  //backup and zerofy page counters
  int backup_num_of_ram_pages = p->num_of_pages_in_phys;
  int backup_num_of_pages = p->num_of_pages;
  p->num_of_pages = 0;
  p->num_of_pages_in_phys = 0;

  #endif

  begin_op();

  if((ip = namei(path)) == 0){
    end_op();
    return -1;
  }
  ilock(ip);

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    goto bad;
  if(elf.magic != ELF_MAGIC)
    goto bad;

  if((pagetable = proc_pagetable(p)) == 0)
    goto bad;

  // Load program into memory. allocate ELF stuff
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
      goto bad;
    uint64 sz1;
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    sz = sz1;
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
  end_op();
  ip = 0;

  p = myproc();
  uint64 oldsz = p->sz;

  // Allocate two pages at the next page boundary.
  // Use the second as the user stack.
  sz = PGROUNDUP(sz);
  uint64 sz1;
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
  sz = sz1;
  uvmclear(pagetable, sz-2*PGSIZE);
  sp = sz;
  stackbase = sp - PGSIZE;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    if(sp < stackbase)
      goto bad;
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[argc] = sp;
  }
  ustack[argc] = 0;

  // push the array of argv[] pointers.
  sp -= (argc+1) * sizeof(uint64);
  sp -= sp % 16;
  if(sp < stackbase)
    goto bad;
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    goto bad;

  // arguments to user main(argc, argv)
  // argc is returned via the system call return
  // value, which goes in a0.
  p->trapframe->a1 = sp;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
    if(*s == '/')
      last = s+1;
  safestrcpy(p->name, last, sizeof(p->name));

  #ifndef NONE
  if (p->pid > 2){
    //remove previous swapfile, we don't want daddy's old files
    if(removeSwapFile(p) < 0)
      goto bad;
    //create a fresh swapfile
    createSwapFile(p);
  }


  // if(myproc()->pid >2)
  // {
  //   for (int i=0; i<MAX_PSYC_PAGES; i++)
  //   {
  //     //now we have 2 pagetables and they can have the same adress to 2 different pages
  //     if(p->files_in_physicalmem[i].isAvailable==0)
  //     {
  //       p->files_in_physicalmem[i].pagetable = pagetable;
  //     }
  //     if(p->files_in_swap[i].isAvailable==0)
  //     {
  //       p->files_in_swap[i].pagetable = pagetable;
  //     }
  //   }
  // }
  #endif

  // Commit to the user image.
  oldpagetable = p->pagetable;
  p->pagetable = pagetable;
  p->sz = sz;
  p->trapframe->epc = elf.entry;  // initial program counter = main
  p->trapframe->sp = sp; // initial stack pointer
  proc_freepagetable(oldpagetable, oldsz);

  return argc; // this ends up in a0, the first argument to main(argc, argv)

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    end_op();
  }
  #ifndef NONE
  //restore backed-up memory arrays
  for(int i=0; i<MAX_PSYC_PAGES; i++){
    memmove((void *)&p->files_in_physicalmem[i], (void *)&old_ram[i], sizeof(struct page_struct));
    // memmove((void *)&p->files_in_swap[i], (void *)&old_swap[i], sizeof(struct page_struct));
  }
  for(int i=0; i<MAX_SWAP_PAGES; i++){
    memmove((void *)&p->files_in_swap[i], (void *)&old_swap[i], sizeof(struct page_struct));
  }
  p->num_of_pages_in_phys = backup_num_of_ram_pages;
  p->num_of_pages = backup_num_of_pages;
  #endif
  return -1;
}

// Load a program segment into pagetable at virtual address va.
// va must be page-aligned
// and the pages from va to va+sz must already be mapped.
// Returns 0 on success, -1 on failure.
static int
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
      return -1;
  }

  return 0;
}
