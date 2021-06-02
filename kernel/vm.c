#include "param.h"
#include "types.h"
#include "memlayout.h"
#include "elf.h"
#include "riscv.h"
#include "defs.h"
#include "fs.h"
//our additions
#include "spinlock.h"
#include "proc.h"


/*
 * the kernel's page table.
 */
pagetable_t kernel_pagetable;

extern char etext[];  // kernel.ld sets this to end of kernel code.

extern char trampoline[]; // trampoline.S

// extern void copy_memory_arrays(struct proc* src, struct proc* dst);

// Make a direct-map page table for the kernel.
pagetable_t
kvmmake(void)
{
  pagetable_t kpgtbl;

  kpgtbl = (pagetable_t) kalloc();
  memset(kpgtbl, 0, PGSIZE);

  // uart registers
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);

  // virtio mmio disk interface
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);

  // PLIC
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);

  // map kernel text executable and read-only.
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);

  // map kernel data and the physical RAM we'll make use of.
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);

  // map the trampoline for trap entry/exit to
  // the highest virtual address in the kernel.
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);

  // map kernel stacks
  proc_mapstacks(kpgtbl);

  return kpgtbl;
}

// Initialize the one kernel_pagetable
void
kvminit(void)
{
  kernel_pagetable = kvmmake();
}

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
  w_satp(MAKE_SATP(kernel_pagetable));
  sfence_vma();
}

// Return the address of the PTE in page table pagetable
// that corresponds to virtual address va.  If alloc!=0,
// create any required page-table pages.
//
// The risc-v Sv39 scheme has three levels of page-table
// pages. A page-table page contains 512 64-bit PTEs.
// A 64-bit virtual address is split into five fields:
//   39..63 -- must be zero.
//   30..38 -- 9 bits of level-2 index.
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
  if(va >= MAXVA)
    panic("walk");

  for(int level = 2; level > 0; level--) {
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0){
        printf("DEBUG, walk couldn't alloc. level: %d\n", level);
        return 0;

      }
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V; //TODO maybe add | PTE_U
    }
  }
  return &pagetable[PX(0, va)];
}

// Look up a virtual address, return the physical address,
// or 0 if not mapped.
// Can only be used to look up user pages.
uint64
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA){
    printf("va >= MAXVA\n");
    return 0;
  }

  pte = walk(pagetable, va, 0);
  if(pte == 0){
    printf("pte == 0\n");
    return 0;
  }

  if((*pte & PTE_V) == 0){
    printf("*pte & PTE_V\n");
    return 0;
  }
  if((*pte & PTE_U) == 0){
    printf("*pte & PTE_U. *pte: %d\n", *pte);
    return 0;
  }
  pa = PTE2PA(*pte);
  return pa;
}

// add a mapping to the kernel page table.
// only used when booting.
// does not flush TLB or enable paging.
void
kvmmap(pagetable_t kpgtbl, uint64 va, uint64 pa, uint64 sz, int perm)
{
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    panic("kvmmap");
}

// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
  last = PGROUNDDOWN(va + size - 1);
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
      return -1;
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}

// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
  // printf("hello from uvmunmap. npages: %d\n", npages);
  // if (myproc()->pid smyproc(), myproc()->files_in_physicalmem);
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE)
  {
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0 && (*pte & PTE_PG) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
      panic("uvmunmap: not a leaf");
    if(do_free && (*pte & PTE_PG) == 0)
    {
      uint64 pa = PTE2PA(*pte);
      // printf("kfree from uvmunmap\n");
      kfree((void*)pa);
    }
    #ifndef NONE
    struct proc *p = myproc();
    //we don't want a process changing its parents' memory
    if((p->pagetable == pagetable) && (p->pid > 2))
    {
      //look in swap array to remove
      for(int i = 0; i < MAX_SWAP_PAGES; i++){
        if((p->files_in_swap[i].isAvailable == 0) && p->files_in_swap[i].va == a){
          // p->files_in_swap[i].va = 0;
          p->files_in_swap[i].isAvailable = 1;
          p->num_of_pages--;
        }
      }
      //find the page in ram array and remove
      for(int i = 0; i < MAX_PSYC_PAGES; i++)
      {
        if((p->files_in_physicalmem[i].isAvailable == 0) && p->files_in_physicalmem[i].va == a)
        {
          p->files_in_physicalmem[i].va = 0;
          p->files_in_physicalmem[i].isAvailable = 1;
          p->num_of_pages--;
          p->num_of_pages_in_phys--;
          //in scfifo we need to update ram array upon page removal
          #ifdef SCFIFO
            //update ram array
            //curr's next's index_of_prev should be updated to curr's prev
            p->files_in_physicalmem[p->files_in_physicalmem[i].index_of_next_p].index_of_prev_p = p->files_in_physicalmem[i].index_of_prev_p;
            //curr's prev's next dhould be updated to curr's next
            p->files_in_physicalmem[p->files_in_physicalmem[i].index_of_prev_p].index_of_next_p = p->files_in_physicalmem[i].index_of_next_p;
            //if the page removed was tail, update new tail
            if(p->index_of_tail_p == i){
              p->index_of_tail_p = p->files_in_physicalmem[i].index_of_prev_p;
            }
            //if the page removed was the head, update new head
            if(p->index_of_head_p == i){
              //if it's the only one in the array, head should now be -1
              if(p->index_of_head_p == p->files_in_physicalmem[i].index_of_next_p){
                p->index_of_head_p = -1;
              }
              //else, head will be the next page
              else {
                p->index_of_head_p = p->files_in_physicalmem[i].index_of_next_p;
              }
              p->files_in_physicalmem[i].index_of_prev_p = -1;
              p->files_in_physicalmem[i].index_of_next_p = -1;
            }
          #endif
        }
        // p->num_of_pages--;
        // p->num_of_pages_in_phys--;
      }
    }
    #endif
    *pte = 0;
  }
  // printf("leaving uvmunmap\n");
  // if(myproc()->pid >2)
    // print_page_array(myproc(), myproc()->files_in_physicalmem);

}

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
  if(pagetable == 0)
    return 0;
  memset(pagetable, 0, PGSIZE);
  return pagetable;
}

// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
  char *mem;

  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
  memmove(mem, src, sz);
}

// Allocate PTEs and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
uint64
uvmalloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
  char *mem;
  uint64 a;

  if(newsz < oldsz)
    return oldsz;

  oldsz = PGROUNDUP(oldsz);

  // int counter = 0;
  for(a = oldsz; a < newsz; a += PGSIZE){

    //OH minute 22
    //check if current process has more pages to give (out of the 32 it has)
    #ifndef NONE
    struct proc* p = myproc();
    if ((p->num_of_pages) >= MAX_TOTAL_PAGES) {
      printf("not enough free pages\n");
      return 0;
    }
    #endif
    mem = kalloc();
    if(mem == 0){
      uvmdealloc(pagetable, a, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
      kfree(mem);
      uvmdealloc(pagetable, a, oldsz);
      return 0;
    }
    #ifndef NONE
    //task 1
    // printf("should not enter here\n");
    if (p->pid > 2 && p->pagetable == pagetable) {
      if (p->num_of_pages_in_phys < MAX_PSYC_PAGES) {
        // printf("num_of_pages_in_phys: %d\n", p->num_of_pages_in_phys);
        add_page_to_phys(p, pagetable, a); //a= va

      } else {
        // printf("DEBUG uvmalloc swapping to file.\n");
        swap_to_swapFile(p, p->pagetable);
        // printf("swap finished\n");
        // printf("swapped ti swapfile\n");
        add_page_to_phys(p, pagetable, a);
      }

    }
    // printf("pid: %d, counter: %d\n", p->pid, counter);
    // counter++;
    #endif
  }
  return newsz;
}

// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
  if(newsz >= oldsz)
    return oldsz;

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    // printf("calling uvmunmap. pid: %d\n", myproc()->pid);
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    }
  }
  kfree((void*)pagetable);
}

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
  if(sz > 0)
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
}

// Given a parent process's page table, copy
// its memory into a child's page table.
// Copies both the page table and the
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walk(old, i, 0)) == 0)
      panic("uvmcopy: pte should exist");
    //if page is invalid, check if it was pages out
    if((*pte & PTE_V) == 0) {
      #ifndef NONE
      //if a page is invalid and was paged out, update child's page accordingly
      if (*pte & PTE_PG) {
        pte_t *new_pte;
        //map a new pte for this page in child. take care of valid and pte_pg flags accordingly
        if((new_pte = walk(new, i, 1)) == 0) {panic("uvmcopy: can't create pte\n");}
        *new_pte |= PTE_PG;
        *new_pte &= ~PTE_V;
        // if((*pte & PTE_U) != 0){*new_pte |= PTE_U;}
        continue;
        // goto cont;
      }
      #endif
      //if we got here, page is invalid AND wasn't paged out
      panic("uvmcopy: page not present");
    }
    // cont:
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
      kfree(mem);
      goto err;
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
  return -1;
}

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;

  pte = walk(pagetable, va, 0);
  if(pte == 0)
    panic("uvmclear");
  *pte &= ~PTE_U;
  // printf("turning off PTE_U\n");
}

// Copy from kernel to user.
// Copy len bytes from src to virtual address dstva in a given page table.
// Return 0 on success, -1 on error.
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    va0 = PGROUNDDOWN(dstva);
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);

    len -= n;
    src += n;
    dstva = va0 + PGSIZE;
  }
  return 0;
}

// Copy from user to kernel.
// Copy len bytes to dst from virtual address srcva in a given page table.
// Return 0 on success, -1 on error.
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    va0 = PGROUNDDOWN(srcva);
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);

    len -= n;
    dst += n;
    srcva = va0 + PGSIZE;
  }
  return 0;
}

// Copy a null-terminated string from user to kernel.
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    va0 = PGROUNDDOWN(srcva);
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    if(n > max)
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
        got_null = 1;
        break;
      } else {
        *dst = *p;
      }
      --n;
      --max;
      p++;
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    return 0;
  } else {
    return -1;
  }
}


// //task 1
// //this function copies from src process to dst process the
// //files_in_swap array and files_in_physicalmem array which are in charge of memory management
// void copy_memory_arrays(struct proc* p, struct proc* np){
//   // printf("COPY_MEMORY_ARRAYS: src->files_in_swap: %d\t\tdst->files_in_swap%d\n", src->files_in_swap, dst->files_in_swap);
//   printf("COPY_MEMORY_ARRAYS, printing src files in ram array:\n");
//   print_page_array(p, p->files_in_physicalmem);
//   printf("COPY_MEMORY_ARRAYS, printing dst files in ram array:\n");
//   print_page_array(np, np->files_in_physicalmem);

//   // for(int i = 0; i < MAX_TOTAL_PAGES; i++){
//   //   dst->files_in_swap[i] = src->files_in_swap[i];
//   // }
//   // for(int i = 0; i < MAX_PSYC_PAGES; i++){
//   //   dst->files_in_physicalmem[i] = src->files_in_physicalmem[i];
//   //   //if the page is in physical memory we want to copy the PTE (to have access to the physical address)
//   //   if(dst->files_in_physicalmem[i].isAvailable == 0){
//   //     dst->files_in_physicalmem[i].page = walk(dst->pagetable, dst->files_in_physicalmem[i].va, 0);
//   //   }
//   // }


//   // for (int i = 0; i < MAX_PSYC_PAGES; i++)
//   //   {
//   //     if (p->files_in_swap[i].isAvailable == 0)
//   //     {
//   //       p->buff = kalloc();
//   //       readFromSwapFile(p, p->buff, PGSIZE*i, PGSIZE);
//   //       writeToSwapFile(np, p->buff, PGSIZE*i, PGSIZE);
//   //       kfree(p->buff);
//   //     }
//   //   }
//   for (int i = 0; i < MAX_PSYC_PAGES; i++)
//   {
//     np->files_in_swap[i] = p->files_in_swap[i];
//     if(p->files_in_swap[i].isAvailable == 0)
//     np->files_in_swap[i].pagetable = np->pagetable;
//     np->files_in_physicalmem[i] = p->files_in_physicalmem[i];
//     if(p->files_in_physicalmem[i].isAvailable == 0)
//     np->files_in_physicalmem[i].pagetable = np->pagetable;
//   }
// }