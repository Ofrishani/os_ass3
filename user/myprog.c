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


int scfifo_test(){
  printmem();
  //allocate 17 memory pages
  char *ret = sbrk(20*PGSIZE);
  // int ret = 5;
  // sbrk(17);
  printf("ret: %d\n", ret);
  //print memory
  printmem();

  return 1;
}

int main(int argc, char *argv[]){
    printf("hello from myprog!\n");
    // scfifo_test();
test_fork_sbrk();
    // printmem();
    //allocate 13 pages and write to page 3 on offset 7 (bytes)
    // char* ptr = sbrk(13*PGSIZE) + 4*PGSIZE + 7;
    // // printmem();
    // strcpy(ptr, "hello");
    // sbrk(17*PGSIZE);

    // printmem();
    printf("after test\n");
    exit(0);
}