#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"
#include "../kernel/syscall.h"
#define O_RDONLY  0x000
#define O_WRONLY  0x001
#define O_RDWR    0x002
#define O_CREATE  0x200
#define O_TRUNC   0x400
#define PGSIZE 4096 // bytes per page

void write_to_pages(char *ptr, int begin, int how_many, int increment){
    for(int i = begin; i < begin+(how_many*increment); i = i+increment){
        // printf("i: %d, ptr: %d\t", i, ptr);
        printf("a very important print\t");
        strcpy(ptr, "whatwhat");
        ptr += (increment*PGSIZE);
    }
    printf("\n");
}

void fork_test() {
    printf("fork test");
    if (!fork()) {
        char *ptr = sbrk(PGSIZE * 15);
        write_to_pages(ptr, 0, 15, 1);
        printf("first child wrote. pid: %d\t", getpid());
        if (!fork()) {
            char *ptr2 = sbrk(PGSIZE * 10);
            write_to_pages(ptr2, 0, 10, 1);
            exit(0);
        } else {
            wait(0);
        }
        printf("second child wrote. pid: %d\n", getpid());
        if (!fork()) {
            char *ptr3 = sbrk(PGSIZE * 10);
            write_to_pages(ptr3, 0, 10, 1);
            exit(0);
        } else {
            wait(0);
        }
        exit(0);
    } else {
        wait(0);
    }
    printf("end fork test");
}

void dealloc_test() {
    printf("dealloc test\n");
    if (!fork()) {
        int *arr = (int *) (sbrk(PGSIZE * 20));
        for (int i = 0; i < PGSIZE * 20 / sizeof(int); ++i) { arr[i] = 0; }
        sbrk(-PGSIZE * 20);
        printf("dealloc complete\n");
        exit(0);
    } else {
        wait(0);
    }
}

//check that fifo works if we don't touch any of the ram pages
int fifo_test(){
    //allocate 16 memory pages (this will fill the ram, 3 pages are allocated beforehand)
    printf("allocating 16 memory pages. printing memory\n");
    char *ret = sbrk(16*PGSIZE);
    printmem();
    printf("reti: %c\n", *ret);
    printf("allocating another page and printing\n");
    //allocate one more page. see that the page replaced is the one in ram index 1
    //(the one in index 0 was accessed. can uncomment line ~1144 in proc.c to be sure)
    ret = sbrk(1*PGSIZE);
    printmem();
    //allocate another page. see that the page replaced is in ram index 0
    printf("allocating another page and printing\n");
    ret = sbrk(1*PGSIZE);
    printmem();
    //now should be index 2
    printf("allocating another page and printing\n");
    ret = sbrk(1*PGSIZE);
    printmem();
    //now should be index 3
    printf("allocating another page and printing\n");
    ret = sbrk(1*PGSIZE);
    printmem();
    //4
    printf("final page allocation and print\n");
    ret = sbrk(1*PGSIZE);
    printmem();
    return 1993;

}


int scfifo_test(){
  printmem();
  //allocate 16 pages and write to page 4 on offset 7 (bytes)
  char* ptr = sbrk(16*PGSIZE) + 4*PGSIZE + 7;
    // // printmem();
  strcpy(ptr, "hello");
  //allocate 5 pages. this write should swap pages
  //0, 1, 2, 3, 5. print memory to see this happen
  sbrk(5*PGSIZE);
  printmem();
  //write to page in index 9
  ptr += 5*PGSIZE;
  strcpy(ptr, "hello");
  printf("written to page in index 9. allocating 5 more pages and printing memory\n");
  sbrk(5*PGSIZE);

  printmem();
  return 1;
}

int nfua_test(){
    printf("hello fron nfua test! memory state:\n");
    printmem();
    //allocate 16 pages and write to pages with even numbers on offset 7 (bytes)
    char* ptr = sbrk(16*PGSIZE) + 7;
    uint64 ptrcpy = (uint64) ptr;
    for(int i = 0; i < 16; i = i+2){
        strcpy(ptr, "hello");
        printf("ptr: %d\n", ptr);
        ptr += 2*PGSIZE;
    }
    printf("written to even pages. now allocating more pages and printing memory after each allocation\n");
    // ptr = sbrk(1*PGSIZE)+8;
    // ptrcpy = (uint64)ptr;
    for(int i = 0; i < 6; i++){
        ptr = sbrk(1*PGSIZE)+8;
        // ptrcpy = (uint64)ptr;
        strcpy(ptr, "hellohello");
        printf("ptr2: %d\n", ptr);
        ptr += PGSIZE;
        //we keep writing to pages because NFUA counter gets updated a lot
        //and we want even pages to stay written to
        write_to_pages((char*)ptrcpy, 0, 8, 2);
        printf("one more page allocated and written to. memory state:\n");
        printmem();
    }
    return 5003;
}

int lapa_test2(){
    printf("hello fron lapa test! memory state:\n");
    printmem();
    //allocate 15 memory pages (fill ram)
    char* ptr = sbrk(16*PGSIZE) + 7;
    // uint64 ptrcpy = (uint64) ptr;
    for(int i=0; i<15; i++){
        //write to all pages except 15
        uint64 ptrcpy = (uint64) ptr;
        // ptrcpy += PGSIZE;
        write_to_pages((char *)ptrcpy, 0, 15, 1);
    }
    // printf("after write to all pages except 15. memory:\n");
    // printmem();
    //write to page in index 15 once
    ptr+=15*PGSIZE;
    strcpy(ptr, "whazuppp");
    printf("after write to page 15. memory:\n");
    //allocate a new page. see that the page replaced is 15
    sbrk(1*PGSIZE);
    printmem();
    return 5003;
}


int lapa_test(){
    printf("hello fron lapa test! memory state:\n");
    printmem();
    //allocate 15 memory pages (fill ram)
    char* ptr = sbrk(16*PGSIZE) + 7;
    //write to page in index 0 5 times
    for(int i=0; i<5; i++){
        strcpy(ptr, "whazuppp");
        ptr+=10;
    }
    //write to all other pages
    ptr += PGSIZE;
    write_to_pages(ptr, 1, 15, 1);
    //allocate a new page. see that the page replaced is NOT 0
    sbrk(1*PGSIZE);
    printmem();
    return 5003;
}

int main(int argc, char *argv[]){
    printf("hello from myprog!\n");
    // fork_test();
    // scfifo_test();
    // nfua_test();
    // lapa_test();
    // lapa_test2();

    // test_fork_sbrk();


    //dealloc_test();

    // fifo_test();

    printf("after test\n");
    exit(0);
}