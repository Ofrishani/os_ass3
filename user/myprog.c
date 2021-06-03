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


void test_fork_sbrk(){
    printf("test test_fork_sbrk\n");
    printf("before allocating 20 pages\n");
    char* arr[32];

    for(int i = 0; i < 10; i++){
        arr[i] = sbrk(PGSIZE);
        printf("father: i is %d\n", i);
    }
    for(int j = 10; j < 20; j++){
        arr[j] = sbrk(PGSIZE);
        arr[j][0] = j;
    }
    printf("finished allocating\n");

    int pid = fork();
    if(pid == 0){
        sleep(10);
       // here there is pagefault in trap
    for(int i = 0; i < 20;i++){
            arr[i][0] = i;
            printf("son: i is %d\n", i);
        }
        exit(0);
    }
    // father wait to son
    else{
        wait(0);
        printf("finished test test_fork_sbrk\n\n");
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
    //(the one in index 0 was accessed. can uncomment line 1136 in proc.c to be sure)
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
  //allocate 5 pages. page 0 is accessed beforehand, this write should swap pages
  //1, 0, 2, 3, 5 in this order. print memory to see this happen
  sbrk(5*PGSIZE);
  printmem();
  return 1;
}

void write_to_pages(char *ptr, int begin, int how_many, int increment){
    for(int i = begin; i < begin+(how_many*increment); i = i+increment){
        printf("i: %d, ptr: %d\n", i, ptr);
        strcpy(ptr, "whatwhat");
        ptr += i+(increment*PGSIZE);
    }
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

int main(int argc, char *argv[]){
    printf("hello from myprog!\n");
    // scfifo_test();
    nfua_test();


    // test_fork_sbrk();
    // printmem();
    //allocate 13 pages and write to page 3 on offset 7 (bytes)
    // char* ptr = sbrk(13*PGSIZE) + 4*PGSIZE + 7;
    // // printmem();
    // strcpy(ptr, "hello");
    // sbrk(17*PGSIZE);

    // printmem();


    // fifo_test();

    printf("after test\n");
    exit(0);
}