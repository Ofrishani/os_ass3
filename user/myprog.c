#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"
#include "../kernel/syscall.h"
#define O_RDONLY  0x000
#define O_WRONLY  0x001
#define O_RDWR    0x002
#define O_CREATE  0x200
#define O_TRUNC   0x400

void
copyin(char *s)
{
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open("copyin1", O_CREATE|O_WRONLY);
    if(fd < 0){
      printf("open(copyin1) failed\n");
      exit(1);
    }
    int n = write(fd, (void*)addr, 8192);
    if(n >= 0){
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
      exit(1);
    }
    close(fd);
    unlink("copyin1");

    n = write(1, (char*)addr, 8192);
    if(n > 0){
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
      exit(1);
    }

    int fds[2];
    if(pipe(fds) < 0){
      printf("pipe() failed\n");
      exit(1);
    }
    n = write(fds[1], (char*)addr, 8192);
    if(n > 0){
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
      exit(1);
    }
    close(fds[0]);
    close(fds[1]);
  }
}

int main(int argc, char *argv[]){
    printf("hello from myprog!\n");
    copyin("hello");
    printf("after test");
    exit(0);
}