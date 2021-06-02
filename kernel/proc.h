#define MAX_PSYC_PAGES 16
#define MAX_TOTAL_PAGES 32
#define MAX_SWAP_PAGES 17

// Saved registers for kernel context switches.
struct context {
  uint64 ra;
  uint64 sp;

  // callee-saved
  uint64 s0;
  uint64 s1;
  uint64 s2;
  uint64 s3;
  uint64 s4;
  uint64 s5;
  uint64 s6;
  uint64 s7;
  uint64 s8;
  uint64 s9;
  uint64 s10;
  uint64 s11;
};

// Per-CPU state.
struct cpu {
  struct proc *proc;          // The process running on this cpu, or null.
  struct context context;     // swtch() here to enter scheduler().
  int noff;                   // Depth of push_off() nesting.
  int intena;                 // Were interrupts enabled before push_off()?
};

extern struct cpu cpus[NCPU];

// per-process data for the trap handling code in trampoline.S.
// sits in a page by itself just under the trampoline page in the
// user page table. not specially mapped in the kernel page table.
// the sscratch register points here.
// uservec in trampoline.S saves user registers in the trapframe,
// then initializes registers from the trapframe's
// kernel_sp, kernel_hartid, kernel_satp, and jumps to kernel_trap.
// usertrapret() and userret in trampoline.S set up
// the trapframe's kernel_*, restore user registers from the
// trapframe, switch to the user page table, and enter user space.
// the trapframe includes callee-saved user registers like s0-s11 because the
// return-to-user path via usertrapret() doesn't return through
// the entire kernel call stack.
struct trapframe {
  /*   0 */ uint64 kernel_satp;   // kernel page table
  /*   8 */ uint64 kernel_sp;     // top of process's kernel stack
  /*  16 */ uint64 kernel_trap;   // usertrap()
  /*  24 */ uint64 epc;           // saved user program counter
  /*  32 */ uint64 kernel_hartid; // saved kernel tp
  /*  40 */ uint64 ra;
  /*  48 */ uint64 sp;
  /*  56 */ uint64 gp;
  /*  64 */ uint64 tp;
  /*  72 */ uint64 t0;
  /*  80 */ uint64 t1;
  /*  88 */ uint64 t2;
  /*  96 */ uint64 s0;
  /* 104 */ uint64 s1;
  /* 112 */ uint64 a0;
  /* 120 */ uint64 a1;
  /* 128 */ uint64 a2;
  /* 136 */ uint64 a3;
  /* 144 */ uint64 a4;
  /* 152 */ uint64 a5;
  /* 160 */ uint64 a6;
  /* 168 */ uint64 a7;
  /* 176 */ uint64 s2;
  /* 184 */ uint64 s3;
  /* 192 */ uint64 s4;
  /* 200 */ uint64 s5;
  /* 208 */ uint64 s6;
  /* 216 */ uint64 s7;
  /* 224 */ uint64 s8;
  /* 232 */ uint64 s9;
  /* 240 */ uint64 s10;
  /* 248 */ uint64 s11;
  /* 256 */ uint64 t3;
  /* 264 */ uint64 t4;
  /* 272 */ uint64 t5;
  /* 280 */ uint64 t6;
};

enum procstate { UNUSED, USED, SLEEPING, RUNNABLE, RUNNING, ZOMBIE };

// task 1
// #ifndef NONE
struct page_struct {
  int isAvailable;  //true if page is not used in virtual memory (otherwise the page is null)
  // int isUsed; //true if page is in physical memory, false if page is in swap_file.
  pagetable_t pagetable;
  pte_t *page; //physical address
  uint64 va; //virtual address
  int offset; //offset in swap file
  //task 2
  #ifdef NFUA
    uint counter_NFUA;
  #endif
  #ifdef LAPA
    uint counter_LAPA;
  #endif
  #ifdef SCFIFO
    int index_of_next_p;
    int index_of_prev_p;
  #endif
};
// #endif


// Per-process state
struct proc {
  struct spinlock lock;

  // p->lock must be held when using these:
  enum procstate state;        // Process state
  void *chan;                  // If non-zero, sleeping on chan
  int killed;                  // If non-zero, have been killed
  int xstate;                  // Exit status to be returned to parent's wait
  int pid;                     // Process ID

  // proc_tree_lock must be held when using this:
  struct proc *parent;         // Parent process

  // these are private to the process, so p->lock need not be held.
  uint64 kstack;               // Virtual address of kernel stack
  uint64 sz;                   // Size of process memory (bytes)
  pagetable_t pagetable;       // User page table
  struct trapframe *trapframe; // data page for trampoline.S
  struct context context;      // swtch() here to run process
  struct file *ofile[NOFILE];  // Open files
  struct inode *cwd;           // Current directory
  char name[16];               // Process name (debugging)
  // #ifndef NONE
  struct file *swapFile;
  // int swapFile_offset;  //points to free space in swapFile
  struct page_struct files_in_swap[MAX_SWAP_PAGES]; // swap file metadata. for each page in process memory, holds a page_struct
  struct page_struct files_in_physicalmem[MAX_PSYC_PAGES];
  int num_of_pages;   //total taken pages in proc
  int num_of_pages_in_phys;   //total taken pages in physical memory
  char* buff;

  //task 2
  #ifdef SCFIFO
    int index_of_head_p;
    int index_of_tail_p;
  #endif
  // #endif
};

// #ifndef NONE
int add_page_to_phys(struct proc *p, uint64* page, uint64 va);
int remove_page_from_phys(struct proc* p, int index);
int add_page_to_swapfile_array(struct proc* p, uint64* page, uint64 va, int offset);
int delete_page_from_file_arr(struct proc* p, int index);
int free_page_from_phys(struct proc* p);
int swap_to_swapFile(struct proc *p, pagetable_t pagetable);
int copy_file(struct proc* dest, struct proc* source);
// void copy_memory_arrays(struct proc* src, struct proc* dst);
void print_page_array(struct proc* p, struct page_struct* pagearr);
int calc_ndx_NFUA(struct proc *p);
int calc_ndx_LAPA(struct proc *p);
int calc_ones(uint nums);
int calc_ndx_for_ramarr_removal(struct proc *p);
void init_meta_data(struct proc* p);
void update_counter_NFUA(struct proc* p);
void update_counter_LAPA(struct proc* p);
// #endif
#ifdef SCFIFO
int calc_ndx_for_scfifo(struct proc *p);
#endif

//task 3
int printmem(void);