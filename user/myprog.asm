
user/_myprog:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyin>:
#define O_CREATE  0x200
#define O_TRUNC   0x400

void
copyin(char *s)
{
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
  10:	4785                	li	a5,1
  12:	07fe                	slli	a5,a5,0x1f
  14:	fcf43023          	sd	a5,-64(s0)
  18:	57fd                	li	a5,-1
  1a:	fcf43423          	sd	a5,-56(s0)

  for(int ai = 0; ai < 2; ai++){
  1e:	fc040913          	addi	s2,s0,-64
    uint64 addr = addrs[ai];

    int fd = open("copyin1", O_CREATE|O_WRONLY);
  22:	00001a17          	auipc	s4,0x1
  26:	946a0a13          	addi	s4,s4,-1722 # 968 <malloc+0xe6>
    uint64 addr = addrs[ai];
  2a:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
  2e:	20100593          	li	a1,513
  32:	8552                	mv	a0,s4
  34:	00000097          	auipc	ra,0x0
  38:	450080e7          	jalr	1104(ra) # 484 <open>
  3c:	84aa                	mv	s1,a0
    if(fd < 0){
  3e:	08054863          	bltz	a0,ce <copyin+0xce>
      printf("open(copyin1) failed\n");
      exit(1);
    }
    int n = write(fd, (void*)addr, 8192);
  42:	6609                	lui	a2,0x2
  44:	85ce                	mv	a1,s3
  46:	00000097          	auipc	ra,0x0
  4a:	41e080e7          	jalr	1054(ra) # 464 <write>
    if(n >= 0){
  4e:	08055d63          	bgez	a0,e8 <copyin+0xe8>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
      exit(1);
    }
    close(fd);
  52:	8526                	mv	a0,s1
  54:	00000097          	auipc	ra,0x0
  58:	418080e7          	jalr	1048(ra) # 46c <close>
    unlink("copyin1");
  5c:	8552                	mv	a0,s4
  5e:	00000097          	auipc	ra,0x0
  62:	436080e7          	jalr	1078(ra) # 494 <unlink>

    n = write(1, (char*)addr, 8192);
  66:	6609                	lui	a2,0x2
  68:	85ce                	mv	a1,s3
  6a:	4505                	li	a0,1
  6c:	00000097          	auipc	ra,0x0
  70:	3f8080e7          	jalr	1016(ra) # 464 <write>
    if(n > 0){
  74:	08a04963          	bgtz	a0,106 <copyin+0x106>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
      exit(1);
    }

    int fds[2];
    if(pipe(fds) < 0){
  78:	fb840513          	addi	a0,s0,-72
  7c:	00000097          	auipc	ra,0x0
  80:	3d8080e7          	jalr	984(ra) # 454 <pipe>
  84:	0a054063          	bltz	a0,124 <copyin+0x124>
      printf("pipe() failed\n");
      exit(1);
    }
    n = write(fds[1], (char*)addr, 8192);
  88:	6609                	lui	a2,0x2
  8a:	85ce                	mv	a1,s3
  8c:	fbc42503          	lw	a0,-68(s0)
  90:	00000097          	auipc	ra,0x0
  94:	3d4080e7          	jalr	980(ra) # 464 <write>
    if(n > 0){
  98:	0aa04363          	bgtz	a0,13e <copyin+0x13e>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
      exit(1);
    }
    close(fds[0]);
  9c:	fb842503          	lw	a0,-72(s0)
  a0:	00000097          	auipc	ra,0x0
  a4:	3cc080e7          	jalr	972(ra) # 46c <close>
    close(fds[1]);
  a8:	fbc42503          	lw	a0,-68(s0)
  ac:	00000097          	auipc	ra,0x0
  b0:	3c0080e7          	jalr	960(ra) # 46c <close>
  for(int ai = 0; ai < 2; ai++){
  b4:	0921                	addi	s2,s2,8
  b6:	fd040793          	addi	a5,s0,-48
  ba:	f6f918e3          	bne	s2,a5,2a <copyin+0x2a>
  }
}
  be:	60a6                	ld	ra,72(sp)
  c0:	6406                	ld	s0,64(sp)
  c2:	74e2                	ld	s1,56(sp)
  c4:	7942                	ld	s2,48(sp)
  c6:	79a2                	ld	s3,40(sp)
  c8:	7a02                	ld	s4,32(sp)
  ca:	6161                	addi	sp,sp,80
  cc:	8082                	ret
      printf("open(copyin1) failed\n");
  ce:	00001517          	auipc	a0,0x1
  d2:	8a250513          	addi	a0,a0,-1886 # 970 <malloc+0xee>
  d6:	00000097          	auipc	ra,0x0
  da:	6ee080e7          	jalr	1774(ra) # 7c4 <printf>
      exit(1);
  de:	4505                	li	a0,1
  e0:	00000097          	auipc	ra,0x0
  e4:	364080e7          	jalr	868(ra) # 444 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
  e8:	862a                	mv	a2,a0
  ea:	85ce                	mv	a1,s3
  ec:	00001517          	auipc	a0,0x1
  f0:	89c50513          	addi	a0,a0,-1892 # 988 <malloc+0x106>
  f4:	00000097          	auipc	ra,0x0
  f8:	6d0080e7          	jalr	1744(ra) # 7c4 <printf>
      exit(1);
  fc:	4505                	li	a0,1
  fe:	00000097          	auipc	ra,0x0
 102:	346080e7          	jalr	838(ra) # 444 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
 106:	862a                	mv	a2,a0
 108:	85ce                	mv	a1,s3
 10a:	00001517          	auipc	a0,0x1
 10e:	8ae50513          	addi	a0,a0,-1874 # 9b8 <malloc+0x136>
 112:	00000097          	auipc	ra,0x0
 116:	6b2080e7          	jalr	1714(ra) # 7c4 <printf>
      exit(1);
 11a:	4505                	li	a0,1
 11c:	00000097          	auipc	ra,0x0
 120:	328080e7          	jalr	808(ra) # 444 <exit>
      printf("pipe() failed\n");
 124:	00001517          	auipc	a0,0x1
 128:	8c450513          	addi	a0,a0,-1852 # 9e8 <malloc+0x166>
 12c:	00000097          	auipc	ra,0x0
 130:	698080e7          	jalr	1688(ra) # 7c4 <printf>
      exit(1);
 134:	4505                	li	a0,1
 136:	00000097          	auipc	ra,0x0
 13a:	30e080e7          	jalr	782(ra) # 444 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
 13e:	862a                	mv	a2,a0
 140:	85ce                	mv	a1,s3
 142:	00001517          	auipc	a0,0x1
 146:	8b650513          	addi	a0,a0,-1866 # 9f8 <malloc+0x176>
 14a:	00000097          	auipc	ra,0x0
 14e:	67a080e7          	jalr	1658(ra) # 7c4 <printf>
      exit(1);
 152:	4505                	li	a0,1
 154:	00000097          	auipc	ra,0x0
 158:	2f0080e7          	jalr	752(ra) # 444 <exit>

000000000000015c <scfifo_test>:

int scfifo_test(){
 15c:	1141                	addi	sp,sp,-16
 15e:	e406                	sd	ra,8(sp)
 160:	e022                	sd	s0,0(sp)
 162:	0800                	addi	s0,sp,16
  printmem();
 164:	00000097          	auipc	ra,0x0
 168:	380080e7          	jalr	896(ra) # 4e4 <printmem>
  //allocate 17 memory pages
  char *ret = sbrk(17);
 16c:	4545                	li	a0,17
 16e:	00000097          	auipc	ra,0x0
 172:	35e080e7          	jalr	862(ra) # 4cc <sbrk>
 176:	85aa                	mv	a1,a0
  // int ret = 5;
  // sbrk(17);
  printf("ret: %d\n", ret);
 178:	00001517          	auipc	a0,0x1
 17c:	8b050513          	addi	a0,a0,-1872 # a28 <malloc+0x1a6>
 180:	00000097          	auipc	ra,0x0
 184:	644080e7          	jalr	1604(ra) # 7c4 <printf>
  //print memory
  printmem();
 188:	00000097          	auipc	ra,0x0
 18c:	35c080e7          	jalr	860(ra) # 4e4 <printmem>

  return 1;
}
 190:	4505                	li	a0,1
 192:	60a2                	ld	ra,8(sp)
 194:	6402                	ld	s0,0(sp)
 196:	0141                	addi	sp,sp,16
 198:	8082                	ret

000000000000019a <main>:

int main(int argc, char *argv[]){
 19a:	1141                	addi	sp,sp,-16
 19c:	e406                	sd	ra,8(sp)
 19e:	e022                	sd	s0,0(sp)
 1a0:	0800                	addi	s0,sp,16
    printf("hello from myprog!\n");
 1a2:	00001517          	auipc	a0,0x1
 1a6:	89650513          	addi	a0,a0,-1898 # a38 <malloc+0x1b6>
 1aa:	00000097          	auipc	ra,0x0
 1ae:	61a080e7          	jalr	1562(ra) # 7c4 <printf>
    // copyin("hello");
    // scfifo_test();
    sbrk(20);
 1b2:	4551                	li	a0,20
 1b4:	00000097          	auipc	ra,0x0
 1b8:	318080e7          	jalr	792(ra) # 4cc <sbrk>
    printf("after test\n");
 1bc:	00001517          	auipc	a0,0x1
 1c0:	89450513          	addi	a0,a0,-1900 # a50 <malloc+0x1ce>
 1c4:	00000097          	auipc	ra,0x0
 1c8:	600080e7          	jalr	1536(ra) # 7c4 <printf>
    exit(0);
 1cc:	4501                	li	a0,0
 1ce:	00000097          	auipc	ra,0x0
 1d2:	276080e7          	jalr	630(ra) # 444 <exit>

00000000000001d6 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1d6:	1141                	addi	sp,sp,-16
 1d8:	e422                	sd	s0,8(sp)
 1da:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1dc:	87aa                	mv	a5,a0
 1de:	0585                	addi	a1,a1,1
 1e0:	0785                	addi	a5,a5,1
 1e2:	fff5c703          	lbu	a4,-1(a1)
 1e6:	fee78fa3          	sb	a4,-1(a5)
 1ea:	fb75                	bnez	a4,1de <strcpy+0x8>
    ;
  return os;
}
 1ec:	6422                	ld	s0,8(sp)
 1ee:	0141                	addi	sp,sp,16
 1f0:	8082                	ret

00000000000001f2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1f2:	1141                	addi	sp,sp,-16
 1f4:	e422                	sd	s0,8(sp)
 1f6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1f8:	00054783          	lbu	a5,0(a0)
 1fc:	cb91                	beqz	a5,210 <strcmp+0x1e>
 1fe:	0005c703          	lbu	a4,0(a1)
 202:	00f71763          	bne	a4,a5,210 <strcmp+0x1e>
    p++, q++;
 206:	0505                	addi	a0,a0,1
 208:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 20a:	00054783          	lbu	a5,0(a0)
 20e:	fbe5                	bnez	a5,1fe <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 210:	0005c503          	lbu	a0,0(a1)
}
 214:	40a7853b          	subw	a0,a5,a0
 218:	6422                	ld	s0,8(sp)
 21a:	0141                	addi	sp,sp,16
 21c:	8082                	ret

000000000000021e <strlen>:

uint
strlen(const char *s)
{
 21e:	1141                	addi	sp,sp,-16
 220:	e422                	sd	s0,8(sp)
 222:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 224:	00054783          	lbu	a5,0(a0)
 228:	cf91                	beqz	a5,244 <strlen+0x26>
 22a:	0505                	addi	a0,a0,1
 22c:	87aa                	mv	a5,a0
 22e:	4685                	li	a3,1
 230:	9e89                	subw	a3,a3,a0
 232:	00f6853b          	addw	a0,a3,a5
 236:	0785                	addi	a5,a5,1
 238:	fff7c703          	lbu	a4,-1(a5)
 23c:	fb7d                	bnez	a4,232 <strlen+0x14>
    ;
  return n;
}
 23e:	6422                	ld	s0,8(sp)
 240:	0141                	addi	sp,sp,16
 242:	8082                	ret
  for(n = 0; s[n]; n++)
 244:	4501                	li	a0,0
 246:	bfe5                	j	23e <strlen+0x20>

0000000000000248 <memset>:

void*
memset(void *dst, int c, uint n)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e422                	sd	s0,8(sp)
 24c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 24e:	ca19                	beqz	a2,264 <memset+0x1c>
 250:	87aa                	mv	a5,a0
 252:	1602                	slli	a2,a2,0x20
 254:	9201                	srli	a2,a2,0x20
 256:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 25a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 25e:	0785                	addi	a5,a5,1
 260:	fee79de3          	bne	a5,a4,25a <memset+0x12>
  }
  return dst;
}
 264:	6422                	ld	s0,8(sp)
 266:	0141                	addi	sp,sp,16
 268:	8082                	ret

000000000000026a <strchr>:

char*
strchr(const char *s, char c)
{
 26a:	1141                	addi	sp,sp,-16
 26c:	e422                	sd	s0,8(sp)
 26e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 270:	00054783          	lbu	a5,0(a0)
 274:	cb99                	beqz	a5,28a <strchr+0x20>
    if(*s == c)
 276:	00f58763          	beq	a1,a5,284 <strchr+0x1a>
  for(; *s; s++)
 27a:	0505                	addi	a0,a0,1
 27c:	00054783          	lbu	a5,0(a0)
 280:	fbfd                	bnez	a5,276 <strchr+0xc>
      return (char*)s;
  return 0;
 282:	4501                	li	a0,0
}
 284:	6422                	ld	s0,8(sp)
 286:	0141                	addi	sp,sp,16
 288:	8082                	ret
  return 0;
 28a:	4501                	li	a0,0
 28c:	bfe5                	j	284 <strchr+0x1a>

000000000000028e <gets>:

char*
gets(char *buf, int max)
{
 28e:	711d                	addi	sp,sp,-96
 290:	ec86                	sd	ra,88(sp)
 292:	e8a2                	sd	s0,80(sp)
 294:	e4a6                	sd	s1,72(sp)
 296:	e0ca                	sd	s2,64(sp)
 298:	fc4e                	sd	s3,56(sp)
 29a:	f852                	sd	s4,48(sp)
 29c:	f456                	sd	s5,40(sp)
 29e:	f05a                	sd	s6,32(sp)
 2a0:	ec5e                	sd	s7,24(sp)
 2a2:	1080                	addi	s0,sp,96
 2a4:	8baa                	mv	s7,a0
 2a6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2a8:	892a                	mv	s2,a0
 2aa:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2ac:	4aa9                	li	s5,10
 2ae:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2b0:	89a6                	mv	s3,s1
 2b2:	2485                	addiw	s1,s1,1
 2b4:	0344d863          	bge	s1,s4,2e4 <gets+0x56>
    cc = read(0, &c, 1);
 2b8:	4605                	li	a2,1
 2ba:	faf40593          	addi	a1,s0,-81
 2be:	4501                	li	a0,0
 2c0:	00000097          	auipc	ra,0x0
 2c4:	19c080e7          	jalr	412(ra) # 45c <read>
    if(cc < 1)
 2c8:	00a05e63          	blez	a0,2e4 <gets+0x56>
    buf[i++] = c;
 2cc:	faf44783          	lbu	a5,-81(s0)
 2d0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2d4:	01578763          	beq	a5,s5,2e2 <gets+0x54>
 2d8:	0905                	addi	s2,s2,1
 2da:	fd679be3          	bne	a5,s6,2b0 <gets+0x22>
  for(i=0; i+1 < max; ){
 2de:	89a6                	mv	s3,s1
 2e0:	a011                	j	2e4 <gets+0x56>
 2e2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2e4:	99de                	add	s3,s3,s7
 2e6:	00098023          	sb	zero,0(s3)
  return buf;
}
 2ea:	855e                	mv	a0,s7
 2ec:	60e6                	ld	ra,88(sp)
 2ee:	6446                	ld	s0,80(sp)
 2f0:	64a6                	ld	s1,72(sp)
 2f2:	6906                	ld	s2,64(sp)
 2f4:	79e2                	ld	s3,56(sp)
 2f6:	7a42                	ld	s4,48(sp)
 2f8:	7aa2                	ld	s5,40(sp)
 2fa:	7b02                	ld	s6,32(sp)
 2fc:	6be2                	ld	s7,24(sp)
 2fe:	6125                	addi	sp,sp,96
 300:	8082                	ret

0000000000000302 <stat>:

int
stat(const char *n, struct stat *st)
{
 302:	1101                	addi	sp,sp,-32
 304:	ec06                	sd	ra,24(sp)
 306:	e822                	sd	s0,16(sp)
 308:	e426                	sd	s1,8(sp)
 30a:	e04a                	sd	s2,0(sp)
 30c:	1000                	addi	s0,sp,32
 30e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 310:	4581                	li	a1,0
 312:	00000097          	auipc	ra,0x0
 316:	172080e7          	jalr	370(ra) # 484 <open>
  if(fd < 0)
 31a:	02054563          	bltz	a0,344 <stat+0x42>
 31e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 320:	85ca                	mv	a1,s2
 322:	00000097          	auipc	ra,0x0
 326:	17a080e7          	jalr	378(ra) # 49c <fstat>
 32a:	892a                	mv	s2,a0
  close(fd);
 32c:	8526                	mv	a0,s1
 32e:	00000097          	auipc	ra,0x0
 332:	13e080e7          	jalr	318(ra) # 46c <close>
  return r;
}
 336:	854a                	mv	a0,s2
 338:	60e2                	ld	ra,24(sp)
 33a:	6442                	ld	s0,16(sp)
 33c:	64a2                	ld	s1,8(sp)
 33e:	6902                	ld	s2,0(sp)
 340:	6105                	addi	sp,sp,32
 342:	8082                	ret
    return -1;
 344:	597d                	li	s2,-1
 346:	bfc5                	j	336 <stat+0x34>

0000000000000348 <atoi>:

int
atoi(const char *s)
{
 348:	1141                	addi	sp,sp,-16
 34a:	e422                	sd	s0,8(sp)
 34c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 34e:	00054603          	lbu	a2,0(a0)
 352:	fd06079b          	addiw	a5,a2,-48
 356:	0ff7f793          	andi	a5,a5,255
 35a:	4725                	li	a4,9
 35c:	02f76963          	bltu	a4,a5,38e <atoi+0x46>
 360:	86aa                	mv	a3,a0
  n = 0;
 362:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 364:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 366:	0685                	addi	a3,a3,1
 368:	0025179b          	slliw	a5,a0,0x2
 36c:	9fa9                	addw	a5,a5,a0
 36e:	0017979b          	slliw	a5,a5,0x1
 372:	9fb1                	addw	a5,a5,a2
 374:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 378:	0006c603          	lbu	a2,0(a3)
 37c:	fd06071b          	addiw	a4,a2,-48
 380:	0ff77713          	andi	a4,a4,255
 384:	fee5f1e3          	bgeu	a1,a4,366 <atoi+0x1e>
  return n;
}
 388:	6422                	ld	s0,8(sp)
 38a:	0141                	addi	sp,sp,16
 38c:	8082                	ret
  n = 0;
 38e:	4501                	li	a0,0
 390:	bfe5                	j	388 <atoi+0x40>

0000000000000392 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 392:	1141                	addi	sp,sp,-16
 394:	e422                	sd	s0,8(sp)
 396:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 398:	02b57463          	bgeu	a0,a1,3c0 <memmove+0x2e>
    while(n-- > 0)
 39c:	00c05f63          	blez	a2,3ba <memmove+0x28>
 3a0:	1602                	slli	a2,a2,0x20
 3a2:	9201                	srli	a2,a2,0x20
 3a4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3a8:	872a                	mv	a4,a0
      *dst++ = *src++;
 3aa:	0585                	addi	a1,a1,1
 3ac:	0705                	addi	a4,a4,1
 3ae:	fff5c683          	lbu	a3,-1(a1)
 3b2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3b6:	fee79ae3          	bne	a5,a4,3aa <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3ba:	6422                	ld	s0,8(sp)
 3bc:	0141                	addi	sp,sp,16
 3be:	8082                	ret
    dst += n;
 3c0:	00c50733          	add	a4,a0,a2
    src += n;
 3c4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3c6:	fec05ae3          	blez	a2,3ba <memmove+0x28>
 3ca:	fff6079b          	addiw	a5,a2,-1
 3ce:	1782                	slli	a5,a5,0x20
 3d0:	9381                	srli	a5,a5,0x20
 3d2:	fff7c793          	not	a5,a5
 3d6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3d8:	15fd                	addi	a1,a1,-1
 3da:	177d                	addi	a4,a4,-1
 3dc:	0005c683          	lbu	a3,0(a1)
 3e0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3e4:	fee79ae3          	bne	a5,a4,3d8 <memmove+0x46>
 3e8:	bfc9                	j	3ba <memmove+0x28>

00000000000003ea <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3ea:	1141                	addi	sp,sp,-16
 3ec:	e422                	sd	s0,8(sp)
 3ee:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3f0:	ca05                	beqz	a2,420 <memcmp+0x36>
 3f2:	fff6069b          	addiw	a3,a2,-1
 3f6:	1682                	slli	a3,a3,0x20
 3f8:	9281                	srli	a3,a3,0x20
 3fa:	0685                	addi	a3,a3,1
 3fc:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3fe:	00054783          	lbu	a5,0(a0)
 402:	0005c703          	lbu	a4,0(a1)
 406:	00e79863          	bne	a5,a4,416 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 40a:	0505                	addi	a0,a0,1
    p2++;
 40c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 40e:	fed518e3          	bne	a0,a3,3fe <memcmp+0x14>
  }
  return 0;
 412:	4501                	li	a0,0
 414:	a019                	j	41a <memcmp+0x30>
      return *p1 - *p2;
 416:	40e7853b          	subw	a0,a5,a4
}
 41a:	6422                	ld	s0,8(sp)
 41c:	0141                	addi	sp,sp,16
 41e:	8082                	ret
  return 0;
 420:	4501                	li	a0,0
 422:	bfe5                	j	41a <memcmp+0x30>

0000000000000424 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 424:	1141                	addi	sp,sp,-16
 426:	e406                	sd	ra,8(sp)
 428:	e022                	sd	s0,0(sp)
 42a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 42c:	00000097          	auipc	ra,0x0
 430:	f66080e7          	jalr	-154(ra) # 392 <memmove>
}
 434:	60a2                	ld	ra,8(sp)
 436:	6402                	ld	s0,0(sp)
 438:	0141                	addi	sp,sp,16
 43a:	8082                	ret

000000000000043c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 43c:	4885                	li	a7,1
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <exit>:
.global exit
exit:
 li a7, SYS_exit
 444:	4889                	li	a7,2
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <wait>:
.global wait
wait:
 li a7, SYS_wait
 44c:	488d                	li	a7,3
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 454:	4891                	li	a7,4
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <read>:
.global read
read:
 li a7, SYS_read
 45c:	4895                	li	a7,5
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <write>:
.global write
write:
 li a7, SYS_write
 464:	48c1                	li	a7,16
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <close>:
.global close
close:
 li a7, SYS_close
 46c:	48d5                	li	a7,21
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <kill>:
.global kill
kill:
 li a7, SYS_kill
 474:	4899                	li	a7,6
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <exec>:
.global exec
exec:
 li a7, SYS_exec
 47c:	489d                	li	a7,7
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <open>:
.global open
open:
 li a7, SYS_open
 484:	48bd                	li	a7,15
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 48c:	48c5                	li	a7,17
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 494:	48c9                	li	a7,18
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 49c:	48a1                	li	a7,8
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <link>:
.global link
link:
 li a7, SYS_link
 4a4:	48cd                	li	a7,19
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4ac:	48d1                	li	a7,20
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4b4:	48a5                	li	a7,9
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <dup>:
.global dup
dup:
 li a7, SYS_dup
 4bc:	48a9                	li	a7,10
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4c4:	48ad                	li	a7,11
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4cc:	48b1                	li	a7,12
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4d4:	48b5                	li	a7,13
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4dc:	48b9                	li	a7,14
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <printmem>:
.global printmem
printmem:
 li a7, SYS_printmem
 4e4:	48d9                	li	a7,22
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ec:	1101                	addi	sp,sp,-32
 4ee:	ec06                	sd	ra,24(sp)
 4f0:	e822                	sd	s0,16(sp)
 4f2:	1000                	addi	s0,sp,32
 4f4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4f8:	4605                	li	a2,1
 4fa:	fef40593          	addi	a1,s0,-17
 4fe:	00000097          	auipc	ra,0x0
 502:	f66080e7          	jalr	-154(ra) # 464 <write>
}
 506:	60e2                	ld	ra,24(sp)
 508:	6442                	ld	s0,16(sp)
 50a:	6105                	addi	sp,sp,32
 50c:	8082                	ret

000000000000050e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 50e:	7139                	addi	sp,sp,-64
 510:	fc06                	sd	ra,56(sp)
 512:	f822                	sd	s0,48(sp)
 514:	f426                	sd	s1,40(sp)
 516:	f04a                	sd	s2,32(sp)
 518:	ec4e                	sd	s3,24(sp)
 51a:	0080                	addi	s0,sp,64
 51c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 51e:	c299                	beqz	a3,524 <printint+0x16>
 520:	0805c863          	bltz	a1,5b0 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 524:	2581                	sext.w	a1,a1
  neg = 0;
 526:	4881                	li	a7,0
 528:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 52c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 52e:	2601                	sext.w	a2,a2
 530:	00000517          	auipc	a0,0x0
 534:	53850513          	addi	a0,a0,1336 # a68 <digits>
 538:	883a                	mv	a6,a4
 53a:	2705                	addiw	a4,a4,1
 53c:	02c5f7bb          	remuw	a5,a1,a2
 540:	1782                	slli	a5,a5,0x20
 542:	9381                	srli	a5,a5,0x20
 544:	97aa                	add	a5,a5,a0
 546:	0007c783          	lbu	a5,0(a5)
 54a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 54e:	0005879b          	sext.w	a5,a1
 552:	02c5d5bb          	divuw	a1,a1,a2
 556:	0685                	addi	a3,a3,1
 558:	fec7f0e3          	bgeu	a5,a2,538 <printint+0x2a>
  if(neg)
 55c:	00088b63          	beqz	a7,572 <printint+0x64>
    buf[i++] = '-';
 560:	fd040793          	addi	a5,s0,-48
 564:	973e                	add	a4,a4,a5
 566:	02d00793          	li	a5,45
 56a:	fef70823          	sb	a5,-16(a4)
 56e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 572:	02e05863          	blez	a4,5a2 <printint+0x94>
 576:	fc040793          	addi	a5,s0,-64
 57a:	00e78933          	add	s2,a5,a4
 57e:	fff78993          	addi	s3,a5,-1
 582:	99ba                	add	s3,s3,a4
 584:	377d                	addiw	a4,a4,-1
 586:	1702                	slli	a4,a4,0x20
 588:	9301                	srli	a4,a4,0x20
 58a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 58e:	fff94583          	lbu	a1,-1(s2)
 592:	8526                	mv	a0,s1
 594:	00000097          	auipc	ra,0x0
 598:	f58080e7          	jalr	-168(ra) # 4ec <putc>
  while(--i >= 0)
 59c:	197d                	addi	s2,s2,-1
 59e:	ff3918e3          	bne	s2,s3,58e <printint+0x80>
}
 5a2:	70e2                	ld	ra,56(sp)
 5a4:	7442                	ld	s0,48(sp)
 5a6:	74a2                	ld	s1,40(sp)
 5a8:	7902                	ld	s2,32(sp)
 5aa:	69e2                	ld	s3,24(sp)
 5ac:	6121                	addi	sp,sp,64
 5ae:	8082                	ret
    x = -xx;
 5b0:	40b005bb          	negw	a1,a1
    neg = 1;
 5b4:	4885                	li	a7,1
    x = -xx;
 5b6:	bf8d                	j	528 <printint+0x1a>

00000000000005b8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5b8:	7119                	addi	sp,sp,-128
 5ba:	fc86                	sd	ra,120(sp)
 5bc:	f8a2                	sd	s0,112(sp)
 5be:	f4a6                	sd	s1,104(sp)
 5c0:	f0ca                	sd	s2,96(sp)
 5c2:	ecce                	sd	s3,88(sp)
 5c4:	e8d2                	sd	s4,80(sp)
 5c6:	e4d6                	sd	s5,72(sp)
 5c8:	e0da                	sd	s6,64(sp)
 5ca:	fc5e                	sd	s7,56(sp)
 5cc:	f862                	sd	s8,48(sp)
 5ce:	f466                	sd	s9,40(sp)
 5d0:	f06a                	sd	s10,32(sp)
 5d2:	ec6e                	sd	s11,24(sp)
 5d4:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5d6:	0005c903          	lbu	s2,0(a1)
 5da:	18090f63          	beqz	s2,778 <vprintf+0x1c0>
 5de:	8aaa                	mv	s5,a0
 5e0:	8b32                	mv	s6,a2
 5e2:	00158493          	addi	s1,a1,1
  state = 0;
 5e6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5e8:	02500a13          	li	s4,37
      if(c == 'd'){
 5ec:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5f0:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5f4:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5f8:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5fc:	00000b97          	auipc	s7,0x0
 600:	46cb8b93          	addi	s7,s7,1132 # a68 <digits>
 604:	a839                	j	622 <vprintf+0x6a>
        putc(fd, c);
 606:	85ca                	mv	a1,s2
 608:	8556                	mv	a0,s5
 60a:	00000097          	auipc	ra,0x0
 60e:	ee2080e7          	jalr	-286(ra) # 4ec <putc>
 612:	a019                	j	618 <vprintf+0x60>
    } else if(state == '%'){
 614:	01498f63          	beq	s3,s4,632 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 618:	0485                	addi	s1,s1,1
 61a:	fff4c903          	lbu	s2,-1(s1)
 61e:	14090d63          	beqz	s2,778 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 622:	0009079b          	sext.w	a5,s2
    if(state == 0){
 626:	fe0997e3          	bnez	s3,614 <vprintf+0x5c>
      if(c == '%'){
 62a:	fd479ee3          	bne	a5,s4,606 <vprintf+0x4e>
        state = '%';
 62e:	89be                	mv	s3,a5
 630:	b7e5                	j	618 <vprintf+0x60>
      if(c == 'd'){
 632:	05878063          	beq	a5,s8,672 <vprintf+0xba>
      } else if(c == 'l') {
 636:	05978c63          	beq	a5,s9,68e <vprintf+0xd6>
      } else if(c == 'x') {
 63a:	07a78863          	beq	a5,s10,6aa <vprintf+0xf2>
      } else if(c == 'p') {
 63e:	09b78463          	beq	a5,s11,6c6 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 642:	07300713          	li	a4,115
 646:	0ce78663          	beq	a5,a4,712 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 64a:	06300713          	li	a4,99
 64e:	0ee78e63          	beq	a5,a4,74a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 652:	11478863          	beq	a5,s4,762 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 656:	85d2                	mv	a1,s4
 658:	8556                	mv	a0,s5
 65a:	00000097          	auipc	ra,0x0
 65e:	e92080e7          	jalr	-366(ra) # 4ec <putc>
        putc(fd, c);
 662:	85ca                	mv	a1,s2
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	e86080e7          	jalr	-378(ra) # 4ec <putc>
      }
      state = 0;
 66e:	4981                	li	s3,0
 670:	b765                	j	618 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 672:	008b0913          	addi	s2,s6,8
 676:	4685                	li	a3,1
 678:	4629                	li	a2,10
 67a:	000b2583          	lw	a1,0(s6)
 67e:	8556                	mv	a0,s5
 680:	00000097          	auipc	ra,0x0
 684:	e8e080e7          	jalr	-370(ra) # 50e <printint>
 688:	8b4a                	mv	s6,s2
      state = 0;
 68a:	4981                	li	s3,0
 68c:	b771                	j	618 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 68e:	008b0913          	addi	s2,s6,8
 692:	4681                	li	a3,0
 694:	4629                	li	a2,10
 696:	000b2583          	lw	a1,0(s6)
 69a:	8556                	mv	a0,s5
 69c:	00000097          	auipc	ra,0x0
 6a0:	e72080e7          	jalr	-398(ra) # 50e <printint>
 6a4:	8b4a                	mv	s6,s2
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	bf85                	j	618 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6aa:	008b0913          	addi	s2,s6,8
 6ae:	4681                	li	a3,0
 6b0:	4641                	li	a2,16
 6b2:	000b2583          	lw	a1,0(s6)
 6b6:	8556                	mv	a0,s5
 6b8:	00000097          	auipc	ra,0x0
 6bc:	e56080e7          	jalr	-426(ra) # 50e <printint>
 6c0:	8b4a                	mv	s6,s2
      state = 0;
 6c2:	4981                	li	s3,0
 6c4:	bf91                	j	618 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6c6:	008b0793          	addi	a5,s6,8
 6ca:	f8f43423          	sd	a5,-120(s0)
 6ce:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6d2:	03000593          	li	a1,48
 6d6:	8556                	mv	a0,s5
 6d8:	00000097          	auipc	ra,0x0
 6dc:	e14080e7          	jalr	-492(ra) # 4ec <putc>
  putc(fd, 'x');
 6e0:	85ea                	mv	a1,s10
 6e2:	8556                	mv	a0,s5
 6e4:	00000097          	auipc	ra,0x0
 6e8:	e08080e7          	jalr	-504(ra) # 4ec <putc>
 6ec:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ee:	03c9d793          	srli	a5,s3,0x3c
 6f2:	97de                	add	a5,a5,s7
 6f4:	0007c583          	lbu	a1,0(a5)
 6f8:	8556                	mv	a0,s5
 6fa:	00000097          	auipc	ra,0x0
 6fe:	df2080e7          	jalr	-526(ra) # 4ec <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 702:	0992                	slli	s3,s3,0x4
 704:	397d                	addiw	s2,s2,-1
 706:	fe0914e3          	bnez	s2,6ee <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 70a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 70e:	4981                	li	s3,0
 710:	b721                	j	618 <vprintf+0x60>
        s = va_arg(ap, char*);
 712:	008b0993          	addi	s3,s6,8
 716:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 71a:	02090163          	beqz	s2,73c <vprintf+0x184>
        while(*s != 0){
 71e:	00094583          	lbu	a1,0(s2)
 722:	c9a1                	beqz	a1,772 <vprintf+0x1ba>
          putc(fd, *s);
 724:	8556                	mv	a0,s5
 726:	00000097          	auipc	ra,0x0
 72a:	dc6080e7          	jalr	-570(ra) # 4ec <putc>
          s++;
 72e:	0905                	addi	s2,s2,1
        while(*s != 0){
 730:	00094583          	lbu	a1,0(s2)
 734:	f9e5                	bnez	a1,724 <vprintf+0x16c>
        s = va_arg(ap, char*);
 736:	8b4e                	mv	s6,s3
      state = 0;
 738:	4981                	li	s3,0
 73a:	bdf9                	j	618 <vprintf+0x60>
          s = "(null)";
 73c:	00000917          	auipc	s2,0x0
 740:	32490913          	addi	s2,s2,804 # a60 <malloc+0x1de>
        while(*s != 0){
 744:	02800593          	li	a1,40
 748:	bff1                	j	724 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 74a:	008b0913          	addi	s2,s6,8
 74e:	000b4583          	lbu	a1,0(s6)
 752:	8556                	mv	a0,s5
 754:	00000097          	auipc	ra,0x0
 758:	d98080e7          	jalr	-616(ra) # 4ec <putc>
 75c:	8b4a                	mv	s6,s2
      state = 0;
 75e:	4981                	li	s3,0
 760:	bd65                	j	618 <vprintf+0x60>
        putc(fd, c);
 762:	85d2                	mv	a1,s4
 764:	8556                	mv	a0,s5
 766:	00000097          	auipc	ra,0x0
 76a:	d86080e7          	jalr	-634(ra) # 4ec <putc>
      state = 0;
 76e:	4981                	li	s3,0
 770:	b565                	j	618 <vprintf+0x60>
        s = va_arg(ap, char*);
 772:	8b4e                	mv	s6,s3
      state = 0;
 774:	4981                	li	s3,0
 776:	b54d                	j	618 <vprintf+0x60>
    }
  }
}
 778:	70e6                	ld	ra,120(sp)
 77a:	7446                	ld	s0,112(sp)
 77c:	74a6                	ld	s1,104(sp)
 77e:	7906                	ld	s2,96(sp)
 780:	69e6                	ld	s3,88(sp)
 782:	6a46                	ld	s4,80(sp)
 784:	6aa6                	ld	s5,72(sp)
 786:	6b06                	ld	s6,64(sp)
 788:	7be2                	ld	s7,56(sp)
 78a:	7c42                	ld	s8,48(sp)
 78c:	7ca2                	ld	s9,40(sp)
 78e:	7d02                	ld	s10,32(sp)
 790:	6de2                	ld	s11,24(sp)
 792:	6109                	addi	sp,sp,128
 794:	8082                	ret

0000000000000796 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 796:	715d                	addi	sp,sp,-80
 798:	ec06                	sd	ra,24(sp)
 79a:	e822                	sd	s0,16(sp)
 79c:	1000                	addi	s0,sp,32
 79e:	e010                	sd	a2,0(s0)
 7a0:	e414                	sd	a3,8(s0)
 7a2:	e818                	sd	a4,16(s0)
 7a4:	ec1c                	sd	a5,24(s0)
 7a6:	03043023          	sd	a6,32(s0)
 7aa:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ae:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7b2:	8622                	mv	a2,s0
 7b4:	00000097          	auipc	ra,0x0
 7b8:	e04080e7          	jalr	-508(ra) # 5b8 <vprintf>
}
 7bc:	60e2                	ld	ra,24(sp)
 7be:	6442                	ld	s0,16(sp)
 7c0:	6161                	addi	sp,sp,80
 7c2:	8082                	ret

00000000000007c4 <printf>:

void
printf(const char *fmt, ...)
{
 7c4:	711d                	addi	sp,sp,-96
 7c6:	ec06                	sd	ra,24(sp)
 7c8:	e822                	sd	s0,16(sp)
 7ca:	1000                	addi	s0,sp,32
 7cc:	e40c                	sd	a1,8(s0)
 7ce:	e810                	sd	a2,16(s0)
 7d0:	ec14                	sd	a3,24(s0)
 7d2:	f018                	sd	a4,32(s0)
 7d4:	f41c                	sd	a5,40(s0)
 7d6:	03043823          	sd	a6,48(s0)
 7da:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7de:	00840613          	addi	a2,s0,8
 7e2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7e6:	85aa                	mv	a1,a0
 7e8:	4505                	li	a0,1
 7ea:	00000097          	auipc	ra,0x0
 7ee:	dce080e7          	jalr	-562(ra) # 5b8 <vprintf>
}
 7f2:	60e2                	ld	ra,24(sp)
 7f4:	6442                	ld	s0,16(sp)
 7f6:	6125                	addi	sp,sp,96
 7f8:	8082                	ret

00000000000007fa <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7fa:	1141                	addi	sp,sp,-16
 7fc:	e422                	sd	s0,8(sp)
 7fe:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 800:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 804:	00000797          	auipc	a5,0x0
 808:	27c7b783          	ld	a5,636(a5) # a80 <freep>
 80c:	a805                	j	83c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 80e:	4618                	lw	a4,8(a2)
 810:	9db9                	addw	a1,a1,a4
 812:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 816:	6398                	ld	a4,0(a5)
 818:	6318                	ld	a4,0(a4)
 81a:	fee53823          	sd	a4,-16(a0)
 81e:	a091                	j	862 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 820:	ff852703          	lw	a4,-8(a0)
 824:	9e39                	addw	a2,a2,a4
 826:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 828:	ff053703          	ld	a4,-16(a0)
 82c:	e398                	sd	a4,0(a5)
 82e:	a099                	j	874 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 830:	6398                	ld	a4,0(a5)
 832:	00e7e463          	bltu	a5,a4,83a <free+0x40>
 836:	00e6ea63          	bltu	a3,a4,84a <free+0x50>
{
 83a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83c:	fed7fae3          	bgeu	a5,a3,830 <free+0x36>
 840:	6398                	ld	a4,0(a5)
 842:	00e6e463          	bltu	a3,a4,84a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 846:	fee7eae3          	bltu	a5,a4,83a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 84a:	ff852583          	lw	a1,-8(a0)
 84e:	6390                	ld	a2,0(a5)
 850:	02059813          	slli	a6,a1,0x20
 854:	01c85713          	srli	a4,a6,0x1c
 858:	9736                	add	a4,a4,a3
 85a:	fae60ae3          	beq	a2,a4,80e <free+0x14>
    bp->s.ptr = p->s.ptr;
 85e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 862:	4790                	lw	a2,8(a5)
 864:	02061593          	slli	a1,a2,0x20
 868:	01c5d713          	srli	a4,a1,0x1c
 86c:	973e                	add	a4,a4,a5
 86e:	fae689e3          	beq	a3,a4,820 <free+0x26>
  } else
    p->s.ptr = bp;
 872:	e394                	sd	a3,0(a5)
  freep = p;
 874:	00000717          	auipc	a4,0x0
 878:	20f73623          	sd	a5,524(a4) # a80 <freep>
}
 87c:	6422                	ld	s0,8(sp)
 87e:	0141                	addi	sp,sp,16
 880:	8082                	ret

0000000000000882 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 882:	7139                	addi	sp,sp,-64
 884:	fc06                	sd	ra,56(sp)
 886:	f822                	sd	s0,48(sp)
 888:	f426                	sd	s1,40(sp)
 88a:	f04a                	sd	s2,32(sp)
 88c:	ec4e                	sd	s3,24(sp)
 88e:	e852                	sd	s4,16(sp)
 890:	e456                	sd	s5,8(sp)
 892:	e05a                	sd	s6,0(sp)
 894:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 896:	02051493          	slli	s1,a0,0x20
 89a:	9081                	srli	s1,s1,0x20
 89c:	04bd                	addi	s1,s1,15
 89e:	8091                	srli	s1,s1,0x4
 8a0:	0014899b          	addiw	s3,s1,1
 8a4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8a6:	00000517          	auipc	a0,0x0
 8aa:	1da53503          	ld	a0,474(a0) # a80 <freep>
 8ae:	c515                	beqz	a0,8da <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b2:	4798                	lw	a4,8(a5)
 8b4:	02977f63          	bgeu	a4,s1,8f2 <malloc+0x70>
 8b8:	8a4e                	mv	s4,s3
 8ba:	0009871b          	sext.w	a4,s3
 8be:	6685                	lui	a3,0x1
 8c0:	00d77363          	bgeu	a4,a3,8c6 <malloc+0x44>
 8c4:	6a05                	lui	s4,0x1
 8c6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ca:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ce:	00000917          	auipc	s2,0x0
 8d2:	1b290913          	addi	s2,s2,434 # a80 <freep>
  if(p == (char*)-1)
 8d6:	5afd                	li	s5,-1
 8d8:	a895                	j	94c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8da:	00000797          	auipc	a5,0x0
 8de:	1ae78793          	addi	a5,a5,430 # a88 <base>
 8e2:	00000717          	auipc	a4,0x0
 8e6:	18f73f23          	sd	a5,414(a4) # a80 <freep>
 8ea:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ec:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8f0:	b7e1                	j	8b8 <malloc+0x36>
      if(p->s.size == nunits)
 8f2:	02e48c63          	beq	s1,a4,92a <malloc+0xa8>
        p->s.size -= nunits;
 8f6:	4137073b          	subw	a4,a4,s3
 8fa:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8fc:	02071693          	slli	a3,a4,0x20
 900:	01c6d713          	srli	a4,a3,0x1c
 904:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 906:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 90a:	00000717          	auipc	a4,0x0
 90e:	16a73b23          	sd	a0,374(a4) # a80 <freep>
      return (void*)(p + 1);
 912:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 916:	70e2                	ld	ra,56(sp)
 918:	7442                	ld	s0,48(sp)
 91a:	74a2                	ld	s1,40(sp)
 91c:	7902                	ld	s2,32(sp)
 91e:	69e2                	ld	s3,24(sp)
 920:	6a42                	ld	s4,16(sp)
 922:	6aa2                	ld	s5,8(sp)
 924:	6b02                	ld	s6,0(sp)
 926:	6121                	addi	sp,sp,64
 928:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 92a:	6398                	ld	a4,0(a5)
 92c:	e118                	sd	a4,0(a0)
 92e:	bff1                	j	90a <malloc+0x88>
  hp->s.size = nu;
 930:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 934:	0541                	addi	a0,a0,16
 936:	00000097          	auipc	ra,0x0
 93a:	ec4080e7          	jalr	-316(ra) # 7fa <free>
  return freep;
 93e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 942:	d971                	beqz	a0,916 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 944:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 946:	4798                	lw	a4,8(a5)
 948:	fa9775e3          	bgeu	a4,s1,8f2 <malloc+0x70>
    if(p == freep)
 94c:	00093703          	ld	a4,0(s2)
 950:	853e                	mv	a0,a5
 952:	fef719e3          	bne	a4,a5,944 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 956:	8552                	mv	a0,s4
 958:	00000097          	auipc	ra,0x0
 95c:	b74080e7          	jalr	-1164(ra) # 4cc <sbrk>
  if(p == (char*)-1)
 960:	fd5518e3          	bne	a0,s5,930 <malloc+0xae>
        return 0;
 964:	4501                	li	a0,0
 966:	bf45                	j	916 <malloc+0x94>
