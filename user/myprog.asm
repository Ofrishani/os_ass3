
user/_myprog:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test_fork_sbrk>:
#define O_CREATE  0x200
#define O_TRUNC   0x400
#define PGSIZE 4096 // bytes per page


void test_fork_sbrk(){
   0:	7129                	addi	sp,sp,-320
   2:	fe06                	sd	ra,312(sp)
   4:	fa22                	sd	s0,304(sp)
   6:	f626                	sd	s1,296(sp)
   8:	f24a                	sd	s2,288(sp)
   a:	ee4e                	sd	s3,280(sp)
   c:	ea52                	sd	s4,272(sp)
   e:	e656                	sd	s5,264(sp)
  10:	0280                	addi	s0,sp,320
    printf("test test_fork_sbrk\n");
  12:	00001517          	auipc	a0,0x1
  16:	90650513          	addi	a0,a0,-1786 # 918 <malloc+0xec>
  1a:	00000097          	auipc	ra,0x0
  1e:	754080e7          	jalr	1876(ra) # 76e <printf>
    printf("before allocating 20 pages\n");
  22:	00001517          	auipc	a0,0x1
  26:	90e50513          	addi	a0,a0,-1778 # 930 <malloc+0x104>
  2a:	00000097          	auipc	ra,0x0
  2e:	744080e7          	jalr	1860(ra) # 76e <printf>
    char* arr[32];

    for(int i = 0; i < 10; i++){
  32:	ec040a93          	addi	s5,s0,-320
    printf("before allocating 20 pages\n");
  36:	8956                	mv	s2,s5
    for(int i = 0; i < 10; i++){
  38:	4481                	li	s1,0
        arr[i] = sbrk(PGSIZE);
        printf("father: i is %d\n", i);
  3a:	00001a17          	auipc	s4,0x1
  3e:	916a0a13          	addi	s4,s4,-1770 # 950 <malloc+0x124>
    for(int i = 0; i < 10; i++){
  42:	49a9                	li	s3,10
        arr[i] = sbrk(PGSIZE);
  44:	6505                	lui	a0,0x1
  46:	00000097          	auipc	ra,0x0
  4a:	430080e7          	jalr	1072(ra) # 476 <sbrk>
  4e:	00a93023          	sd	a0,0(s2)
        printf("father: i is %d\n", i);
  52:	85a6                	mv	a1,s1
  54:	8552                	mv	a0,s4
  56:	00000097          	auipc	ra,0x0
  5a:	718080e7          	jalr	1816(ra) # 76e <printf>
    for(int i = 0; i < 10; i++){
  5e:	2485                	addiw	s1,s1,1
  60:	0921                	addi	s2,s2,8
  62:	ff3491e3          	bne	s1,s3,44 <test_fork_sbrk+0x44>
  66:	f1040913          	addi	s2,s0,-240
    }
    for(int j = 10; j < 20; j++){
  6a:	49d1                	li	s3,20
        arr[j] = sbrk(PGSIZE);
  6c:	6505                	lui	a0,0x1
  6e:	00000097          	auipc	ra,0x0
  72:	408080e7          	jalr	1032(ra) # 476 <sbrk>
  76:	00a93023          	sd	a0,0(s2)
        arr[j][0] = j;
  7a:	00950023          	sb	s1,0(a0) # 1000 <__BSS_END__+0x5e0>
    for(int j = 10; j < 20; j++){
  7e:	2485                	addiw	s1,s1,1
  80:	0921                	addi	s2,s2,8
  82:	ff3495e3          	bne	s1,s3,6c <test_fork_sbrk+0x6c>
    }
    printf("finished allocating\n");
  86:	00001517          	auipc	a0,0x1
  8a:	8e250513          	addi	a0,a0,-1822 # 968 <malloc+0x13c>
  8e:	00000097          	auipc	ra,0x0
  92:	6e0080e7          	jalr	1760(ra) # 76e <printf>

    int pid = fork();
  96:	00000097          	auipc	ra,0x0
  9a:	350080e7          	jalr	848(ra) # 3e6 <fork>
  9e:	84aa                	mv	s1,a0
    if(pid == 0){
  a0:	c51d                	beqz	a0,ce <test_fork_sbrk+0xce>
        }
        exit(0);
    }
    // father wait to son
    else{
        wait(0);
  a2:	4501                	li	a0,0
  a4:	00000097          	auipc	ra,0x0
  a8:	352080e7          	jalr	850(ra) # 3f6 <wait>
        printf("finished test test_fork_sbrk\n\n");
  ac:	00001517          	auipc	a0,0x1
  b0:	8e450513          	addi	a0,a0,-1820 # 990 <malloc+0x164>
  b4:	00000097          	auipc	ra,0x0
  b8:	6ba080e7          	jalr	1722(ra) # 76e <printf>
    }
}
  bc:	70f2                	ld	ra,312(sp)
  be:	7452                	ld	s0,304(sp)
  c0:	74b2                	ld	s1,296(sp)
  c2:	7912                	ld	s2,288(sp)
  c4:	69f2                	ld	s3,280(sp)
  c6:	6a52                	ld	s4,272(sp)
  c8:	6ab2                	ld	s5,264(sp)
  ca:	6131                	addi	sp,sp,320
  cc:	8082                	ret
        sleep(10);
  ce:	4529                	li	a0,10
  d0:	00000097          	auipc	ra,0x0
  d4:	3ae080e7          	jalr	942(ra) # 47e <sleep>
            printf("son: i is %d\n", i);
  d8:	00001997          	auipc	s3,0x1
  dc:	8a898993          	addi	s3,s3,-1880 # 980 <malloc+0x154>
    for(int i = 0; i < 20;i++){
  e0:	4951                	li	s2,20
            arr[i][0] = i;
  e2:	000ab783          	ld	a5,0(s5)
  e6:	00978023          	sb	s1,0(a5)
            printf("son: i is %d\n", i);
  ea:	85a6                	mv	a1,s1
  ec:	854e                	mv	a0,s3
  ee:	00000097          	auipc	ra,0x0
  f2:	680080e7          	jalr	1664(ra) # 76e <printf>
    for(int i = 0; i < 20;i++){
  f6:	2485                	addiw	s1,s1,1
  f8:	0aa1                	addi	s5,s5,8
  fa:	ff2494e3          	bne	s1,s2,e2 <test_fork_sbrk+0xe2>
        exit(0);
  fe:	4501                	li	a0,0
 100:	00000097          	auipc	ra,0x0
 104:	2ee080e7          	jalr	750(ra) # 3ee <exit>

0000000000000108 <scfifo_test>:


int scfifo_test(){
 108:	1141                	addi	sp,sp,-16
 10a:	e406                	sd	ra,8(sp)
 10c:	e022                	sd	s0,0(sp)
 10e:	0800                	addi	s0,sp,16
  printmem();
 110:	00000097          	auipc	ra,0x0
 114:	37e080e7          	jalr	894(ra) # 48e <printmem>
  //allocate 17 memory pages
  char *ret = sbrk(20*PGSIZE);
 118:	6551                	lui	a0,0x14
 11a:	00000097          	auipc	ra,0x0
 11e:	35c080e7          	jalr	860(ra) # 476 <sbrk>
 122:	85aa                	mv	a1,a0
  // int ret = 5;
  // sbrk(17);
  printf("ret: %d\n", ret);
 124:	00001517          	auipc	a0,0x1
 128:	88c50513          	addi	a0,a0,-1908 # 9b0 <malloc+0x184>
 12c:	00000097          	auipc	ra,0x0
 130:	642080e7          	jalr	1602(ra) # 76e <printf>
  //print memory
  printmem();
 134:	00000097          	auipc	ra,0x0
 138:	35a080e7          	jalr	858(ra) # 48e <printmem>

  return 1;
}
 13c:	4505                	li	a0,1
 13e:	60a2                	ld	ra,8(sp)
 140:	6402                	ld	s0,0(sp)
 142:	0141                	addi	sp,sp,16
 144:	8082                	ret

0000000000000146 <main>:

int main(int argc, char *argv[]){
 146:	1141                	addi	sp,sp,-16
 148:	e406                	sd	ra,8(sp)
 14a:	e022                	sd	s0,0(sp)
 14c:	0800                	addi	s0,sp,16
    printf("hello from myprog!\n");
 14e:	00001517          	auipc	a0,0x1
 152:	87250513          	addi	a0,a0,-1934 # 9c0 <malloc+0x194>
 156:	00000097          	auipc	ra,0x0
 15a:	618080e7          	jalr	1560(ra) # 76e <printf>
    // scfifo_test();
test_fork_sbrk();
 15e:	00000097          	auipc	ra,0x0
 162:	ea2080e7          	jalr	-350(ra) # 0 <test_fork_sbrk>
    // // printmem();
    // strcpy(ptr, "hello");
    // sbrk(17*PGSIZE);

    // printmem();
    printf("after test\n");
 166:	00001517          	auipc	a0,0x1
 16a:	87250513          	addi	a0,a0,-1934 # 9d8 <malloc+0x1ac>
 16e:	00000097          	auipc	ra,0x0
 172:	600080e7          	jalr	1536(ra) # 76e <printf>
    exit(0);
 176:	4501                	li	a0,0
 178:	00000097          	auipc	ra,0x0
 17c:	276080e7          	jalr	630(ra) # 3ee <exit>

0000000000000180 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 180:	1141                	addi	sp,sp,-16
 182:	e422                	sd	s0,8(sp)
 184:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 186:	87aa                	mv	a5,a0
 188:	0585                	addi	a1,a1,1
 18a:	0785                	addi	a5,a5,1
 18c:	fff5c703          	lbu	a4,-1(a1)
 190:	fee78fa3          	sb	a4,-1(a5)
 194:	fb75                	bnez	a4,188 <strcpy+0x8>
    ;
  return os;
}
 196:	6422                	ld	s0,8(sp)
 198:	0141                	addi	sp,sp,16
 19a:	8082                	ret

000000000000019c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 19c:	1141                	addi	sp,sp,-16
 19e:	e422                	sd	s0,8(sp)
 1a0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1a2:	00054783          	lbu	a5,0(a0)
 1a6:	cb91                	beqz	a5,1ba <strcmp+0x1e>
 1a8:	0005c703          	lbu	a4,0(a1)
 1ac:	00f71763          	bne	a4,a5,1ba <strcmp+0x1e>
    p++, q++;
 1b0:	0505                	addi	a0,a0,1
 1b2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1b4:	00054783          	lbu	a5,0(a0)
 1b8:	fbe5                	bnez	a5,1a8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1ba:	0005c503          	lbu	a0,0(a1)
}
 1be:	40a7853b          	subw	a0,a5,a0
 1c2:	6422                	ld	s0,8(sp)
 1c4:	0141                	addi	sp,sp,16
 1c6:	8082                	ret

00000000000001c8 <strlen>:

uint
strlen(const char *s)
{
 1c8:	1141                	addi	sp,sp,-16
 1ca:	e422                	sd	s0,8(sp)
 1cc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ce:	00054783          	lbu	a5,0(a0)
 1d2:	cf91                	beqz	a5,1ee <strlen+0x26>
 1d4:	0505                	addi	a0,a0,1
 1d6:	87aa                	mv	a5,a0
 1d8:	4685                	li	a3,1
 1da:	9e89                	subw	a3,a3,a0
 1dc:	00f6853b          	addw	a0,a3,a5
 1e0:	0785                	addi	a5,a5,1
 1e2:	fff7c703          	lbu	a4,-1(a5)
 1e6:	fb7d                	bnez	a4,1dc <strlen+0x14>
    ;
  return n;
}
 1e8:	6422                	ld	s0,8(sp)
 1ea:	0141                	addi	sp,sp,16
 1ec:	8082                	ret
  for(n = 0; s[n]; n++)
 1ee:	4501                	li	a0,0
 1f0:	bfe5                	j	1e8 <strlen+0x20>

00000000000001f2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1f2:	1141                	addi	sp,sp,-16
 1f4:	e422                	sd	s0,8(sp)
 1f6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1f8:	ca19                	beqz	a2,20e <memset+0x1c>
 1fa:	87aa                	mv	a5,a0
 1fc:	1602                	slli	a2,a2,0x20
 1fe:	9201                	srli	a2,a2,0x20
 200:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 204:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 208:	0785                	addi	a5,a5,1
 20a:	fee79de3          	bne	a5,a4,204 <memset+0x12>
  }
  return dst;
}
 20e:	6422                	ld	s0,8(sp)
 210:	0141                	addi	sp,sp,16
 212:	8082                	ret

0000000000000214 <strchr>:

char*
strchr(const char *s, char c)
{
 214:	1141                	addi	sp,sp,-16
 216:	e422                	sd	s0,8(sp)
 218:	0800                	addi	s0,sp,16
  for(; *s; s++)
 21a:	00054783          	lbu	a5,0(a0)
 21e:	cb99                	beqz	a5,234 <strchr+0x20>
    if(*s == c)
 220:	00f58763          	beq	a1,a5,22e <strchr+0x1a>
  for(; *s; s++)
 224:	0505                	addi	a0,a0,1
 226:	00054783          	lbu	a5,0(a0)
 22a:	fbfd                	bnez	a5,220 <strchr+0xc>
      return (char*)s;
  return 0;
 22c:	4501                	li	a0,0
}
 22e:	6422                	ld	s0,8(sp)
 230:	0141                	addi	sp,sp,16
 232:	8082                	ret
  return 0;
 234:	4501                	li	a0,0
 236:	bfe5                	j	22e <strchr+0x1a>

0000000000000238 <gets>:

char*
gets(char *buf, int max)
{
 238:	711d                	addi	sp,sp,-96
 23a:	ec86                	sd	ra,88(sp)
 23c:	e8a2                	sd	s0,80(sp)
 23e:	e4a6                	sd	s1,72(sp)
 240:	e0ca                	sd	s2,64(sp)
 242:	fc4e                	sd	s3,56(sp)
 244:	f852                	sd	s4,48(sp)
 246:	f456                	sd	s5,40(sp)
 248:	f05a                	sd	s6,32(sp)
 24a:	ec5e                	sd	s7,24(sp)
 24c:	1080                	addi	s0,sp,96
 24e:	8baa                	mv	s7,a0
 250:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 252:	892a                	mv	s2,a0
 254:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 256:	4aa9                	li	s5,10
 258:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 25a:	89a6                	mv	s3,s1
 25c:	2485                	addiw	s1,s1,1
 25e:	0344d863          	bge	s1,s4,28e <gets+0x56>
    cc = read(0, &c, 1);
 262:	4605                	li	a2,1
 264:	faf40593          	addi	a1,s0,-81
 268:	4501                	li	a0,0
 26a:	00000097          	auipc	ra,0x0
 26e:	19c080e7          	jalr	412(ra) # 406 <read>
    if(cc < 1)
 272:	00a05e63          	blez	a0,28e <gets+0x56>
    buf[i++] = c;
 276:	faf44783          	lbu	a5,-81(s0)
 27a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 27e:	01578763          	beq	a5,s5,28c <gets+0x54>
 282:	0905                	addi	s2,s2,1
 284:	fd679be3          	bne	a5,s6,25a <gets+0x22>
  for(i=0; i+1 < max; ){
 288:	89a6                	mv	s3,s1
 28a:	a011                	j	28e <gets+0x56>
 28c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 28e:	99de                	add	s3,s3,s7
 290:	00098023          	sb	zero,0(s3)
  return buf;
}
 294:	855e                	mv	a0,s7
 296:	60e6                	ld	ra,88(sp)
 298:	6446                	ld	s0,80(sp)
 29a:	64a6                	ld	s1,72(sp)
 29c:	6906                	ld	s2,64(sp)
 29e:	79e2                	ld	s3,56(sp)
 2a0:	7a42                	ld	s4,48(sp)
 2a2:	7aa2                	ld	s5,40(sp)
 2a4:	7b02                	ld	s6,32(sp)
 2a6:	6be2                	ld	s7,24(sp)
 2a8:	6125                	addi	sp,sp,96
 2aa:	8082                	ret

00000000000002ac <stat>:

int
stat(const char *n, struct stat *st)
{
 2ac:	1101                	addi	sp,sp,-32
 2ae:	ec06                	sd	ra,24(sp)
 2b0:	e822                	sd	s0,16(sp)
 2b2:	e426                	sd	s1,8(sp)
 2b4:	e04a                	sd	s2,0(sp)
 2b6:	1000                	addi	s0,sp,32
 2b8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ba:	4581                	li	a1,0
 2bc:	00000097          	auipc	ra,0x0
 2c0:	172080e7          	jalr	370(ra) # 42e <open>
  if(fd < 0)
 2c4:	02054563          	bltz	a0,2ee <stat+0x42>
 2c8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2ca:	85ca                	mv	a1,s2
 2cc:	00000097          	auipc	ra,0x0
 2d0:	17a080e7          	jalr	378(ra) # 446 <fstat>
 2d4:	892a                	mv	s2,a0
  close(fd);
 2d6:	8526                	mv	a0,s1
 2d8:	00000097          	auipc	ra,0x0
 2dc:	13e080e7          	jalr	318(ra) # 416 <close>
  return r;
}
 2e0:	854a                	mv	a0,s2
 2e2:	60e2                	ld	ra,24(sp)
 2e4:	6442                	ld	s0,16(sp)
 2e6:	64a2                	ld	s1,8(sp)
 2e8:	6902                	ld	s2,0(sp)
 2ea:	6105                	addi	sp,sp,32
 2ec:	8082                	ret
    return -1;
 2ee:	597d                	li	s2,-1
 2f0:	bfc5                	j	2e0 <stat+0x34>

00000000000002f2 <atoi>:

int
atoi(const char *s)
{
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e422                	sd	s0,8(sp)
 2f6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2f8:	00054603          	lbu	a2,0(a0)
 2fc:	fd06079b          	addiw	a5,a2,-48
 300:	0ff7f793          	andi	a5,a5,255
 304:	4725                	li	a4,9
 306:	02f76963          	bltu	a4,a5,338 <atoi+0x46>
 30a:	86aa                	mv	a3,a0
  n = 0;
 30c:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 30e:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 310:	0685                	addi	a3,a3,1
 312:	0025179b          	slliw	a5,a0,0x2
 316:	9fa9                	addw	a5,a5,a0
 318:	0017979b          	slliw	a5,a5,0x1
 31c:	9fb1                	addw	a5,a5,a2
 31e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 322:	0006c603          	lbu	a2,0(a3)
 326:	fd06071b          	addiw	a4,a2,-48
 32a:	0ff77713          	andi	a4,a4,255
 32e:	fee5f1e3          	bgeu	a1,a4,310 <atoi+0x1e>
  return n;
}
 332:	6422                	ld	s0,8(sp)
 334:	0141                	addi	sp,sp,16
 336:	8082                	ret
  n = 0;
 338:	4501                	li	a0,0
 33a:	bfe5                	j	332 <atoi+0x40>

000000000000033c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 33c:	1141                	addi	sp,sp,-16
 33e:	e422                	sd	s0,8(sp)
 340:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 342:	02b57463          	bgeu	a0,a1,36a <memmove+0x2e>
    while(n-- > 0)
 346:	00c05f63          	blez	a2,364 <memmove+0x28>
 34a:	1602                	slli	a2,a2,0x20
 34c:	9201                	srli	a2,a2,0x20
 34e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 352:	872a                	mv	a4,a0
      *dst++ = *src++;
 354:	0585                	addi	a1,a1,1
 356:	0705                	addi	a4,a4,1
 358:	fff5c683          	lbu	a3,-1(a1)
 35c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 360:	fee79ae3          	bne	a5,a4,354 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 364:	6422                	ld	s0,8(sp)
 366:	0141                	addi	sp,sp,16
 368:	8082                	ret
    dst += n;
 36a:	00c50733          	add	a4,a0,a2
    src += n;
 36e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 370:	fec05ae3          	blez	a2,364 <memmove+0x28>
 374:	fff6079b          	addiw	a5,a2,-1
 378:	1782                	slli	a5,a5,0x20
 37a:	9381                	srli	a5,a5,0x20
 37c:	fff7c793          	not	a5,a5
 380:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 382:	15fd                	addi	a1,a1,-1
 384:	177d                	addi	a4,a4,-1
 386:	0005c683          	lbu	a3,0(a1)
 38a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 38e:	fee79ae3          	bne	a5,a4,382 <memmove+0x46>
 392:	bfc9                	j	364 <memmove+0x28>

0000000000000394 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 394:	1141                	addi	sp,sp,-16
 396:	e422                	sd	s0,8(sp)
 398:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 39a:	ca05                	beqz	a2,3ca <memcmp+0x36>
 39c:	fff6069b          	addiw	a3,a2,-1
 3a0:	1682                	slli	a3,a3,0x20
 3a2:	9281                	srli	a3,a3,0x20
 3a4:	0685                	addi	a3,a3,1
 3a6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3a8:	00054783          	lbu	a5,0(a0)
 3ac:	0005c703          	lbu	a4,0(a1)
 3b0:	00e79863          	bne	a5,a4,3c0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3b4:	0505                	addi	a0,a0,1
    p2++;
 3b6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3b8:	fed518e3          	bne	a0,a3,3a8 <memcmp+0x14>
  }
  return 0;
 3bc:	4501                	li	a0,0
 3be:	a019                	j	3c4 <memcmp+0x30>
      return *p1 - *p2;
 3c0:	40e7853b          	subw	a0,a5,a4
}
 3c4:	6422                	ld	s0,8(sp)
 3c6:	0141                	addi	sp,sp,16
 3c8:	8082                	ret
  return 0;
 3ca:	4501                	li	a0,0
 3cc:	bfe5                	j	3c4 <memcmp+0x30>

00000000000003ce <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3ce:	1141                	addi	sp,sp,-16
 3d0:	e406                	sd	ra,8(sp)
 3d2:	e022                	sd	s0,0(sp)
 3d4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3d6:	00000097          	auipc	ra,0x0
 3da:	f66080e7          	jalr	-154(ra) # 33c <memmove>
}
 3de:	60a2                	ld	ra,8(sp)
 3e0:	6402                	ld	s0,0(sp)
 3e2:	0141                	addi	sp,sp,16
 3e4:	8082                	ret

00000000000003e6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3e6:	4885                	li	a7,1
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ee:	4889                	li	a7,2
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3f6:	488d                	li	a7,3
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3fe:	4891                	li	a7,4
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <read>:
.global read
read:
 li a7, SYS_read
 406:	4895                	li	a7,5
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <write>:
.global write
write:
 li a7, SYS_write
 40e:	48c1                	li	a7,16
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <close>:
.global close
close:
 li a7, SYS_close
 416:	48d5                	li	a7,21
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <kill>:
.global kill
kill:
 li a7, SYS_kill
 41e:	4899                	li	a7,6
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <exec>:
.global exec
exec:
 li a7, SYS_exec
 426:	489d                	li	a7,7
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <open>:
.global open
open:
 li a7, SYS_open
 42e:	48bd                	li	a7,15
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 436:	48c5                	li	a7,17
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 43e:	48c9                	li	a7,18
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 446:	48a1                	li	a7,8
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <link>:
.global link
link:
 li a7, SYS_link
 44e:	48cd                	li	a7,19
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 456:	48d1                	li	a7,20
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 45e:	48a5                	li	a7,9
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <dup>:
.global dup
dup:
 li a7, SYS_dup
 466:	48a9                	li	a7,10
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 46e:	48ad                	li	a7,11
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 476:	48b1                	li	a7,12
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 47e:	48b5                	li	a7,13
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 486:	48b9                	li	a7,14
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <printmem>:
.global printmem
printmem:
 li a7, SYS_printmem
 48e:	48d9                	li	a7,22
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 496:	1101                	addi	sp,sp,-32
 498:	ec06                	sd	ra,24(sp)
 49a:	e822                	sd	s0,16(sp)
 49c:	1000                	addi	s0,sp,32
 49e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4a2:	4605                	li	a2,1
 4a4:	fef40593          	addi	a1,s0,-17
 4a8:	00000097          	auipc	ra,0x0
 4ac:	f66080e7          	jalr	-154(ra) # 40e <write>
}
 4b0:	60e2                	ld	ra,24(sp)
 4b2:	6442                	ld	s0,16(sp)
 4b4:	6105                	addi	sp,sp,32
 4b6:	8082                	ret

00000000000004b8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4b8:	7139                	addi	sp,sp,-64
 4ba:	fc06                	sd	ra,56(sp)
 4bc:	f822                	sd	s0,48(sp)
 4be:	f426                	sd	s1,40(sp)
 4c0:	f04a                	sd	s2,32(sp)
 4c2:	ec4e                	sd	s3,24(sp)
 4c4:	0080                	addi	s0,sp,64
 4c6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4c8:	c299                	beqz	a3,4ce <printint+0x16>
 4ca:	0805c863          	bltz	a1,55a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4ce:	2581                	sext.w	a1,a1
  neg = 0;
 4d0:	4881                	li	a7,0
 4d2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4d6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4d8:	2601                	sext.w	a2,a2
 4da:	00000517          	auipc	a0,0x0
 4de:	51650513          	addi	a0,a0,1302 # 9f0 <digits>
 4e2:	883a                	mv	a6,a4
 4e4:	2705                	addiw	a4,a4,1
 4e6:	02c5f7bb          	remuw	a5,a1,a2
 4ea:	1782                	slli	a5,a5,0x20
 4ec:	9381                	srli	a5,a5,0x20
 4ee:	97aa                	add	a5,a5,a0
 4f0:	0007c783          	lbu	a5,0(a5)
 4f4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4f8:	0005879b          	sext.w	a5,a1
 4fc:	02c5d5bb          	divuw	a1,a1,a2
 500:	0685                	addi	a3,a3,1
 502:	fec7f0e3          	bgeu	a5,a2,4e2 <printint+0x2a>
  if(neg)
 506:	00088b63          	beqz	a7,51c <printint+0x64>
    buf[i++] = '-';
 50a:	fd040793          	addi	a5,s0,-48
 50e:	973e                	add	a4,a4,a5
 510:	02d00793          	li	a5,45
 514:	fef70823          	sb	a5,-16(a4)
 518:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 51c:	02e05863          	blez	a4,54c <printint+0x94>
 520:	fc040793          	addi	a5,s0,-64
 524:	00e78933          	add	s2,a5,a4
 528:	fff78993          	addi	s3,a5,-1
 52c:	99ba                	add	s3,s3,a4
 52e:	377d                	addiw	a4,a4,-1
 530:	1702                	slli	a4,a4,0x20
 532:	9301                	srli	a4,a4,0x20
 534:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 538:	fff94583          	lbu	a1,-1(s2)
 53c:	8526                	mv	a0,s1
 53e:	00000097          	auipc	ra,0x0
 542:	f58080e7          	jalr	-168(ra) # 496 <putc>
  while(--i >= 0)
 546:	197d                	addi	s2,s2,-1
 548:	ff3918e3          	bne	s2,s3,538 <printint+0x80>
}
 54c:	70e2                	ld	ra,56(sp)
 54e:	7442                	ld	s0,48(sp)
 550:	74a2                	ld	s1,40(sp)
 552:	7902                	ld	s2,32(sp)
 554:	69e2                	ld	s3,24(sp)
 556:	6121                	addi	sp,sp,64
 558:	8082                	ret
    x = -xx;
 55a:	40b005bb          	negw	a1,a1
    neg = 1;
 55e:	4885                	li	a7,1
    x = -xx;
 560:	bf8d                	j	4d2 <printint+0x1a>

0000000000000562 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 562:	7119                	addi	sp,sp,-128
 564:	fc86                	sd	ra,120(sp)
 566:	f8a2                	sd	s0,112(sp)
 568:	f4a6                	sd	s1,104(sp)
 56a:	f0ca                	sd	s2,96(sp)
 56c:	ecce                	sd	s3,88(sp)
 56e:	e8d2                	sd	s4,80(sp)
 570:	e4d6                	sd	s5,72(sp)
 572:	e0da                	sd	s6,64(sp)
 574:	fc5e                	sd	s7,56(sp)
 576:	f862                	sd	s8,48(sp)
 578:	f466                	sd	s9,40(sp)
 57a:	f06a                	sd	s10,32(sp)
 57c:	ec6e                	sd	s11,24(sp)
 57e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 580:	0005c903          	lbu	s2,0(a1)
 584:	18090f63          	beqz	s2,722 <vprintf+0x1c0>
 588:	8aaa                	mv	s5,a0
 58a:	8b32                	mv	s6,a2
 58c:	00158493          	addi	s1,a1,1
  state = 0;
 590:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 592:	02500a13          	li	s4,37
      if(c == 'd'){
 596:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 59a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 59e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5a2:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5a6:	00000b97          	auipc	s7,0x0
 5aa:	44ab8b93          	addi	s7,s7,1098 # 9f0 <digits>
 5ae:	a839                	j	5cc <vprintf+0x6a>
        putc(fd, c);
 5b0:	85ca                	mv	a1,s2
 5b2:	8556                	mv	a0,s5
 5b4:	00000097          	auipc	ra,0x0
 5b8:	ee2080e7          	jalr	-286(ra) # 496 <putc>
 5bc:	a019                	j	5c2 <vprintf+0x60>
    } else if(state == '%'){
 5be:	01498f63          	beq	s3,s4,5dc <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5c2:	0485                	addi	s1,s1,1
 5c4:	fff4c903          	lbu	s2,-1(s1)
 5c8:	14090d63          	beqz	s2,722 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5cc:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5d0:	fe0997e3          	bnez	s3,5be <vprintf+0x5c>
      if(c == '%'){
 5d4:	fd479ee3          	bne	a5,s4,5b0 <vprintf+0x4e>
        state = '%';
 5d8:	89be                	mv	s3,a5
 5da:	b7e5                	j	5c2 <vprintf+0x60>
      if(c == 'd'){
 5dc:	05878063          	beq	a5,s8,61c <vprintf+0xba>
      } else if(c == 'l') {
 5e0:	05978c63          	beq	a5,s9,638 <vprintf+0xd6>
      } else if(c == 'x') {
 5e4:	07a78863          	beq	a5,s10,654 <vprintf+0xf2>
      } else if(c == 'p') {
 5e8:	09b78463          	beq	a5,s11,670 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5ec:	07300713          	li	a4,115
 5f0:	0ce78663          	beq	a5,a4,6bc <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5f4:	06300713          	li	a4,99
 5f8:	0ee78e63          	beq	a5,a4,6f4 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5fc:	11478863          	beq	a5,s4,70c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 600:	85d2                	mv	a1,s4
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	e92080e7          	jalr	-366(ra) # 496 <putc>
        putc(fd, c);
 60c:	85ca                	mv	a1,s2
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	e86080e7          	jalr	-378(ra) # 496 <putc>
      }
      state = 0;
 618:	4981                	li	s3,0
 61a:	b765                	j	5c2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 61c:	008b0913          	addi	s2,s6,8
 620:	4685                	li	a3,1
 622:	4629                	li	a2,10
 624:	000b2583          	lw	a1,0(s6)
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	e8e080e7          	jalr	-370(ra) # 4b8 <printint>
 632:	8b4a                	mv	s6,s2
      state = 0;
 634:	4981                	li	s3,0
 636:	b771                	j	5c2 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 638:	008b0913          	addi	s2,s6,8
 63c:	4681                	li	a3,0
 63e:	4629                	li	a2,10
 640:	000b2583          	lw	a1,0(s6)
 644:	8556                	mv	a0,s5
 646:	00000097          	auipc	ra,0x0
 64a:	e72080e7          	jalr	-398(ra) # 4b8 <printint>
 64e:	8b4a                	mv	s6,s2
      state = 0;
 650:	4981                	li	s3,0
 652:	bf85                	j	5c2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 654:	008b0913          	addi	s2,s6,8
 658:	4681                	li	a3,0
 65a:	4641                	li	a2,16
 65c:	000b2583          	lw	a1,0(s6)
 660:	8556                	mv	a0,s5
 662:	00000097          	auipc	ra,0x0
 666:	e56080e7          	jalr	-426(ra) # 4b8 <printint>
 66a:	8b4a                	mv	s6,s2
      state = 0;
 66c:	4981                	li	s3,0
 66e:	bf91                	j	5c2 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 670:	008b0793          	addi	a5,s6,8
 674:	f8f43423          	sd	a5,-120(s0)
 678:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 67c:	03000593          	li	a1,48
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	e14080e7          	jalr	-492(ra) # 496 <putc>
  putc(fd, 'x');
 68a:	85ea                	mv	a1,s10
 68c:	8556                	mv	a0,s5
 68e:	00000097          	auipc	ra,0x0
 692:	e08080e7          	jalr	-504(ra) # 496 <putc>
 696:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 698:	03c9d793          	srli	a5,s3,0x3c
 69c:	97de                	add	a5,a5,s7
 69e:	0007c583          	lbu	a1,0(a5)
 6a2:	8556                	mv	a0,s5
 6a4:	00000097          	auipc	ra,0x0
 6a8:	df2080e7          	jalr	-526(ra) # 496 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6ac:	0992                	slli	s3,s3,0x4
 6ae:	397d                	addiw	s2,s2,-1
 6b0:	fe0914e3          	bnez	s2,698 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6b4:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6b8:	4981                	li	s3,0
 6ba:	b721                	j	5c2 <vprintf+0x60>
        s = va_arg(ap, char*);
 6bc:	008b0993          	addi	s3,s6,8
 6c0:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6c4:	02090163          	beqz	s2,6e6 <vprintf+0x184>
        while(*s != 0){
 6c8:	00094583          	lbu	a1,0(s2)
 6cc:	c9a1                	beqz	a1,71c <vprintf+0x1ba>
          putc(fd, *s);
 6ce:	8556                	mv	a0,s5
 6d0:	00000097          	auipc	ra,0x0
 6d4:	dc6080e7          	jalr	-570(ra) # 496 <putc>
          s++;
 6d8:	0905                	addi	s2,s2,1
        while(*s != 0){
 6da:	00094583          	lbu	a1,0(s2)
 6de:	f9e5                	bnez	a1,6ce <vprintf+0x16c>
        s = va_arg(ap, char*);
 6e0:	8b4e                	mv	s6,s3
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	bdf9                	j	5c2 <vprintf+0x60>
          s = "(null)";
 6e6:	00000917          	auipc	s2,0x0
 6ea:	30290913          	addi	s2,s2,770 # 9e8 <malloc+0x1bc>
        while(*s != 0){
 6ee:	02800593          	li	a1,40
 6f2:	bff1                	j	6ce <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6f4:	008b0913          	addi	s2,s6,8
 6f8:	000b4583          	lbu	a1,0(s6)
 6fc:	8556                	mv	a0,s5
 6fe:	00000097          	auipc	ra,0x0
 702:	d98080e7          	jalr	-616(ra) # 496 <putc>
 706:	8b4a                	mv	s6,s2
      state = 0;
 708:	4981                	li	s3,0
 70a:	bd65                	j	5c2 <vprintf+0x60>
        putc(fd, c);
 70c:	85d2                	mv	a1,s4
 70e:	8556                	mv	a0,s5
 710:	00000097          	auipc	ra,0x0
 714:	d86080e7          	jalr	-634(ra) # 496 <putc>
      state = 0;
 718:	4981                	li	s3,0
 71a:	b565                	j	5c2 <vprintf+0x60>
        s = va_arg(ap, char*);
 71c:	8b4e                	mv	s6,s3
      state = 0;
 71e:	4981                	li	s3,0
 720:	b54d                	j	5c2 <vprintf+0x60>
    }
  }
}
 722:	70e6                	ld	ra,120(sp)
 724:	7446                	ld	s0,112(sp)
 726:	74a6                	ld	s1,104(sp)
 728:	7906                	ld	s2,96(sp)
 72a:	69e6                	ld	s3,88(sp)
 72c:	6a46                	ld	s4,80(sp)
 72e:	6aa6                	ld	s5,72(sp)
 730:	6b06                	ld	s6,64(sp)
 732:	7be2                	ld	s7,56(sp)
 734:	7c42                	ld	s8,48(sp)
 736:	7ca2                	ld	s9,40(sp)
 738:	7d02                	ld	s10,32(sp)
 73a:	6de2                	ld	s11,24(sp)
 73c:	6109                	addi	sp,sp,128
 73e:	8082                	ret

0000000000000740 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 740:	715d                	addi	sp,sp,-80
 742:	ec06                	sd	ra,24(sp)
 744:	e822                	sd	s0,16(sp)
 746:	1000                	addi	s0,sp,32
 748:	e010                	sd	a2,0(s0)
 74a:	e414                	sd	a3,8(s0)
 74c:	e818                	sd	a4,16(s0)
 74e:	ec1c                	sd	a5,24(s0)
 750:	03043023          	sd	a6,32(s0)
 754:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 758:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 75c:	8622                	mv	a2,s0
 75e:	00000097          	auipc	ra,0x0
 762:	e04080e7          	jalr	-508(ra) # 562 <vprintf>
}
 766:	60e2                	ld	ra,24(sp)
 768:	6442                	ld	s0,16(sp)
 76a:	6161                	addi	sp,sp,80
 76c:	8082                	ret

000000000000076e <printf>:

void
printf(const char *fmt, ...)
{
 76e:	711d                	addi	sp,sp,-96
 770:	ec06                	sd	ra,24(sp)
 772:	e822                	sd	s0,16(sp)
 774:	1000                	addi	s0,sp,32
 776:	e40c                	sd	a1,8(s0)
 778:	e810                	sd	a2,16(s0)
 77a:	ec14                	sd	a3,24(s0)
 77c:	f018                	sd	a4,32(s0)
 77e:	f41c                	sd	a5,40(s0)
 780:	03043823          	sd	a6,48(s0)
 784:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 788:	00840613          	addi	a2,s0,8
 78c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 790:	85aa                	mv	a1,a0
 792:	4505                	li	a0,1
 794:	00000097          	auipc	ra,0x0
 798:	dce080e7          	jalr	-562(ra) # 562 <vprintf>
}
 79c:	60e2                	ld	ra,24(sp)
 79e:	6442                	ld	s0,16(sp)
 7a0:	6125                	addi	sp,sp,96
 7a2:	8082                	ret

00000000000007a4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7a4:	1141                	addi	sp,sp,-16
 7a6:	e422                	sd	s0,8(sp)
 7a8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7aa:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ae:	00000797          	auipc	a5,0x0
 7b2:	25a7b783          	ld	a5,602(a5) # a08 <freep>
 7b6:	a805                	j	7e6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7b8:	4618                	lw	a4,8(a2)
 7ba:	9db9                	addw	a1,a1,a4
 7bc:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7c0:	6398                	ld	a4,0(a5)
 7c2:	6318                	ld	a4,0(a4)
 7c4:	fee53823          	sd	a4,-16(a0)
 7c8:	a091                	j	80c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ca:	ff852703          	lw	a4,-8(a0)
 7ce:	9e39                	addw	a2,a2,a4
 7d0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7d2:	ff053703          	ld	a4,-16(a0)
 7d6:	e398                	sd	a4,0(a5)
 7d8:	a099                	j	81e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7da:	6398                	ld	a4,0(a5)
 7dc:	00e7e463          	bltu	a5,a4,7e4 <free+0x40>
 7e0:	00e6ea63          	bltu	a3,a4,7f4 <free+0x50>
{
 7e4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e6:	fed7fae3          	bgeu	a5,a3,7da <free+0x36>
 7ea:	6398                	ld	a4,0(a5)
 7ec:	00e6e463          	bltu	a3,a4,7f4 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f0:	fee7eae3          	bltu	a5,a4,7e4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7f4:	ff852583          	lw	a1,-8(a0)
 7f8:	6390                	ld	a2,0(a5)
 7fa:	02059813          	slli	a6,a1,0x20
 7fe:	01c85713          	srli	a4,a6,0x1c
 802:	9736                	add	a4,a4,a3
 804:	fae60ae3          	beq	a2,a4,7b8 <free+0x14>
    bp->s.ptr = p->s.ptr;
 808:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 80c:	4790                	lw	a2,8(a5)
 80e:	02061593          	slli	a1,a2,0x20
 812:	01c5d713          	srli	a4,a1,0x1c
 816:	973e                	add	a4,a4,a5
 818:	fae689e3          	beq	a3,a4,7ca <free+0x26>
  } else
    p->s.ptr = bp;
 81c:	e394                	sd	a3,0(a5)
  freep = p;
 81e:	00000717          	auipc	a4,0x0
 822:	1ef73523          	sd	a5,490(a4) # a08 <freep>
}
 826:	6422                	ld	s0,8(sp)
 828:	0141                	addi	sp,sp,16
 82a:	8082                	ret

000000000000082c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 82c:	7139                	addi	sp,sp,-64
 82e:	fc06                	sd	ra,56(sp)
 830:	f822                	sd	s0,48(sp)
 832:	f426                	sd	s1,40(sp)
 834:	f04a                	sd	s2,32(sp)
 836:	ec4e                	sd	s3,24(sp)
 838:	e852                	sd	s4,16(sp)
 83a:	e456                	sd	s5,8(sp)
 83c:	e05a                	sd	s6,0(sp)
 83e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 840:	02051493          	slli	s1,a0,0x20
 844:	9081                	srli	s1,s1,0x20
 846:	04bd                	addi	s1,s1,15
 848:	8091                	srli	s1,s1,0x4
 84a:	0014899b          	addiw	s3,s1,1
 84e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 850:	00000517          	auipc	a0,0x0
 854:	1b853503          	ld	a0,440(a0) # a08 <freep>
 858:	c515                	beqz	a0,884 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 85a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 85c:	4798                	lw	a4,8(a5)
 85e:	02977f63          	bgeu	a4,s1,89c <malloc+0x70>
 862:	8a4e                	mv	s4,s3
 864:	0009871b          	sext.w	a4,s3
 868:	6685                	lui	a3,0x1
 86a:	00d77363          	bgeu	a4,a3,870 <malloc+0x44>
 86e:	6a05                	lui	s4,0x1
 870:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 874:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 878:	00000917          	auipc	s2,0x0
 87c:	19090913          	addi	s2,s2,400 # a08 <freep>
  if(p == (char*)-1)
 880:	5afd                	li	s5,-1
 882:	a895                	j	8f6 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 884:	00000797          	auipc	a5,0x0
 888:	18c78793          	addi	a5,a5,396 # a10 <base>
 88c:	00000717          	auipc	a4,0x0
 890:	16f73e23          	sd	a5,380(a4) # a08 <freep>
 894:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 896:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 89a:	b7e1                	j	862 <malloc+0x36>
      if(p->s.size == nunits)
 89c:	02e48c63          	beq	s1,a4,8d4 <malloc+0xa8>
        p->s.size -= nunits;
 8a0:	4137073b          	subw	a4,a4,s3
 8a4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8a6:	02071693          	slli	a3,a4,0x20
 8aa:	01c6d713          	srli	a4,a3,0x1c
 8ae:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8b0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8b4:	00000717          	auipc	a4,0x0
 8b8:	14a73a23          	sd	a0,340(a4) # a08 <freep>
      return (void*)(p + 1);
 8bc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8c0:	70e2                	ld	ra,56(sp)
 8c2:	7442                	ld	s0,48(sp)
 8c4:	74a2                	ld	s1,40(sp)
 8c6:	7902                	ld	s2,32(sp)
 8c8:	69e2                	ld	s3,24(sp)
 8ca:	6a42                	ld	s4,16(sp)
 8cc:	6aa2                	ld	s5,8(sp)
 8ce:	6b02                	ld	s6,0(sp)
 8d0:	6121                	addi	sp,sp,64
 8d2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8d4:	6398                	ld	a4,0(a5)
 8d6:	e118                	sd	a4,0(a0)
 8d8:	bff1                	j	8b4 <malloc+0x88>
  hp->s.size = nu;
 8da:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8de:	0541                	addi	a0,a0,16
 8e0:	00000097          	auipc	ra,0x0
 8e4:	ec4080e7          	jalr	-316(ra) # 7a4 <free>
  return freep;
 8e8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8ec:	d971                	beqz	a0,8c0 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ee:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f0:	4798                	lw	a4,8(a5)
 8f2:	fa9775e3          	bgeu	a4,s1,89c <malloc+0x70>
    if(p == freep)
 8f6:	00093703          	ld	a4,0(s2)
 8fa:	853e                	mv	a0,a5
 8fc:	fef719e3          	bne	a4,a5,8ee <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 900:	8552                	mv	a0,s4
 902:	00000097          	auipc	ra,0x0
 906:	b74080e7          	jalr	-1164(ra) # 476 <sbrk>
  if(p == (char*)-1)
 90a:	fd5518e3          	bne	a0,s5,8da <malloc+0xae>
        return 0;
 90e:	4501                	li	a0,0
 910:	bf45                	j	8c0 <malloc+0x94>
