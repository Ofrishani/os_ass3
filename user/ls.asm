
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "user/user.h"
#include "kernel/fs.h"

char*
fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
  10:	00000097          	auipc	ra,0x0
  14:	342080e7          	jalr	834(ra) # 352 <strlen>
  18:	02051793          	slli	a5,a0,0x20
  1c:	9381                	srli	a5,a5,0x20
  1e:	97a6                	add	a5,a5,s1
  20:	02f00693          	li	a3,47
  24:	0097e963          	bltu	a5,s1,36 <fmtname+0x36>
  28:	0007c703          	lbu	a4,0(a5)
  2c:	00d70563          	beq	a4,a3,36 <fmtname+0x36>
  30:	17fd                	addi	a5,a5,-1
  32:	fe97fbe3          	bgeu	a5,s1,28 <fmtname+0x28>
    ;
  p++;
  36:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  3a:	8526                	mv	a0,s1
  3c:	00000097          	auipc	ra,0x0
  40:	316080e7          	jalr	790(ra) # 352 <strlen>
  44:	2501                	sext.w	a0,a0
  46:	47b5                	li	a5,13
  48:	00a7fa63          	bgeu	a5,a0,5c <fmtname+0x5c>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}
  4c:	8526                	mv	a0,s1
  4e:	70a2                	ld	ra,40(sp)
  50:	7402                	ld	s0,32(sp)
  52:	64e2                	ld	s1,24(sp)
  54:	6942                	ld	s2,16(sp)
  56:	69a2                	ld	s3,8(sp)
  58:	6145                	addi	sp,sp,48
  5a:	8082                	ret
  memmove(buf, p, strlen(p));
  5c:	8526                	mv	a0,s1
  5e:	00000097          	auipc	ra,0x0
  62:	2f4080e7          	jalr	756(ra) # 352 <strlen>
  66:	00001997          	auipc	s3,0x1
  6a:	b0a98993          	addi	s3,s3,-1270 # b70 <buf.0>
  6e:	0005061b          	sext.w	a2,a0
  72:	85a6                	mv	a1,s1
  74:	854e                	mv	a0,s3
  76:	00000097          	auipc	ra,0x0
  7a:	450080e7          	jalr	1104(ra) # 4c6 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  7e:	8526                	mv	a0,s1
  80:	00000097          	auipc	ra,0x0
  84:	2d2080e7          	jalr	722(ra) # 352 <strlen>
  88:	0005091b          	sext.w	s2,a0
  8c:	8526                	mv	a0,s1
  8e:	00000097          	auipc	ra,0x0
  92:	2c4080e7          	jalr	708(ra) # 352 <strlen>
  96:	1902                	slli	s2,s2,0x20
  98:	02095913          	srli	s2,s2,0x20
  9c:	4639                	li	a2,14
  9e:	9e09                	subw	a2,a2,a0
  a0:	02000593          	li	a1,32
  a4:	01298533          	add	a0,s3,s2
  a8:	00000097          	auipc	ra,0x0
  ac:	2d4080e7          	jalr	724(ra) # 37c <memset>
  return buf;
  b0:	84ce                	mv	s1,s3
  b2:	bf69                	j	4c <fmtname+0x4c>

00000000000000b4 <ls>:

void
ls(char *path)
{
  b4:	d9010113          	addi	sp,sp,-624
  b8:	26113423          	sd	ra,616(sp)
  bc:	26813023          	sd	s0,608(sp)
  c0:	24913c23          	sd	s1,600(sp)
  c4:	25213823          	sd	s2,592(sp)
  c8:	25313423          	sd	s3,584(sp)
  cc:	25413023          	sd	s4,576(sp)
  d0:	23513c23          	sd	s5,568(sp)
  d4:	1c80                	addi	s0,sp,624
  d6:	892a                	mv	s2,a0
  printf("hello from ls\n");
  d8:	00001517          	auipc	a0,0x1
  dc:	9c850513          	addi	a0,a0,-1592 # aa0 <malloc+0xea>
  e0:	00001097          	auipc	ra,0x1
  e4:	818080e7          	jalr	-2024(ra) # 8f8 <printf>
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  e8:	4581                	li	a1,0
  ea:	854a                	mv	a0,s2
  ec:	00000097          	auipc	ra,0x0
  f0:	4cc080e7          	jalr	1228(ra) # 5b8 <open>
  f4:	08054763          	bltz	a0,182 <ls+0xce>
  f8:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  fa:	d9840593          	addi	a1,s0,-616
  fe:	00000097          	auipc	ra,0x0
 102:	4d2080e7          	jalr	1234(ra) # 5d0 <fstat>
 106:	08054963          	bltz	a0,198 <ls+0xe4>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
 10a:	da041783          	lh	a5,-608(s0)
 10e:	0007869b          	sext.w	a3,a5
 112:	4705                	li	a4,1
 114:	0ae68263          	beq	a3,a4,1b8 <ls+0x104>
 118:	4709                	li	a4,2
 11a:	02e69663          	bne	a3,a4,146 <ls+0x92>
  case T_FILE:
    printf("%s %d %d %l\n", fmtname(path), st.type, st.ino, st.size);
 11e:	854a                	mv	a0,s2
 120:	00000097          	auipc	ra,0x0
 124:	ee0080e7          	jalr	-288(ra) # 0 <fmtname>
 128:	85aa                	mv	a1,a0
 12a:	da843703          	ld	a4,-600(s0)
 12e:	d9c42683          	lw	a3,-612(s0)
 132:	da041603          	lh	a2,-608(s0)
 136:	00001517          	auipc	a0,0x1
 13a:	9aa50513          	addi	a0,a0,-1622 # ae0 <malloc+0x12a>
 13e:	00000097          	auipc	ra,0x0
 142:	7ba080e7          	jalr	1978(ra) # 8f8 <printf>
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
 146:	8526                	mv	a0,s1
 148:	00000097          	auipc	ra,0x0
 14c:	458080e7          	jalr	1112(ra) # 5a0 <close>
  printf("goodbye from ls\n");
 150:	00001517          	auipc	a0,0x1
 154:	9c850513          	addi	a0,a0,-1592 # b18 <malloc+0x162>
 158:	00000097          	auipc	ra,0x0
 15c:	7a0080e7          	jalr	1952(ra) # 8f8 <printf>
}
 160:	26813083          	ld	ra,616(sp)
 164:	26013403          	ld	s0,608(sp)
 168:	25813483          	ld	s1,600(sp)
 16c:	25013903          	ld	s2,592(sp)
 170:	24813983          	ld	s3,584(sp)
 174:	24013a03          	ld	s4,576(sp)
 178:	23813a83          	ld	s5,568(sp)
 17c:	27010113          	addi	sp,sp,624
 180:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 182:	864a                	mv	a2,s2
 184:	00001597          	auipc	a1,0x1
 188:	92c58593          	addi	a1,a1,-1748 # ab0 <malloc+0xfa>
 18c:	4509                	li	a0,2
 18e:	00000097          	auipc	ra,0x0
 192:	73c080e7          	jalr	1852(ra) # 8ca <fprintf>
    return;
 196:	b7e9                	j	160 <ls+0xac>
    fprintf(2, "ls: cannot stat %s\n", path);
 198:	864a                	mv	a2,s2
 19a:	00001597          	auipc	a1,0x1
 19e:	92e58593          	addi	a1,a1,-1746 # ac8 <malloc+0x112>
 1a2:	4509                	li	a0,2
 1a4:	00000097          	auipc	ra,0x0
 1a8:	726080e7          	jalr	1830(ra) # 8ca <fprintf>
    close(fd);
 1ac:	8526                	mv	a0,s1
 1ae:	00000097          	auipc	ra,0x0
 1b2:	3f2080e7          	jalr	1010(ra) # 5a0 <close>
    return;
 1b6:	b76d                	j	160 <ls+0xac>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 1b8:	854a                	mv	a0,s2
 1ba:	00000097          	auipc	ra,0x0
 1be:	198080e7          	jalr	408(ra) # 352 <strlen>
 1c2:	2541                	addiw	a0,a0,16
 1c4:	20000793          	li	a5,512
 1c8:	00a7fb63          	bgeu	a5,a0,1de <ls+0x12a>
      printf("ls: path too long\n");
 1cc:	00001517          	auipc	a0,0x1
 1d0:	92450513          	addi	a0,a0,-1756 # af0 <malloc+0x13a>
 1d4:	00000097          	auipc	ra,0x0
 1d8:	724080e7          	jalr	1828(ra) # 8f8 <printf>
      break;
 1dc:	b7ad                	j	146 <ls+0x92>
    strcpy(buf, path);
 1de:	85ca                	mv	a1,s2
 1e0:	dc040513          	addi	a0,s0,-576
 1e4:	00000097          	auipc	ra,0x0
 1e8:	126080e7          	jalr	294(ra) # 30a <strcpy>
    p = buf+strlen(buf);
 1ec:	dc040513          	addi	a0,s0,-576
 1f0:	00000097          	auipc	ra,0x0
 1f4:	162080e7          	jalr	354(ra) # 352 <strlen>
 1f8:	02051913          	slli	s2,a0,0x20
 1fc:	02095913          	srli	s2,s2,0x20
 200:	dc040793          	addi	a5,s0,-576
 204:	993e                	add	s2,s2,a5
    *p++ = '/';
 206:	00190993          	addi	s3,s2,1
 20a:	02f00793          	li	a5,47
 20e:	00f90023          	sb	a5,0(s2)
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 212:	00001a17          	auipc	s4,0x1
 216:	8f6a0a13          	addi	s4,s4,-1802 # b08 <malloc+0x152>
        printf("ls: cannot stat %s\n", buf);
 21a:	00001a97          	auipc	s5,0x1
 21e:	8aea8a93          	addi	s5,s5,-1874 # ac8 <malloc+0x112>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 222:	a801                	j	232 <ls+0x17e>
        printf("ls: cannot stat %s\n", buf);
 224:	dc040593          	addi	a1,s0,-576
 228:	8556                	mv	a0,s5
 22a:	00000097          	auipc	ra,0x0
 22e:	6ce080e7          	jalr	1742(ra) # 8f8 <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 232:	4641                	li	a2,16
 234:	db040593          	addi	a1,s0,-592
 238:	8526                	mv	a0,s1
 23a:	00000097          	auipc	ra,0x0
 23e:	356080e7          	jalr	854(ra) # 590 <read>
 242:	47c1                	li	a5,16
 244:	f0f511e3          	bne	a0,a5,146 <ls+0x92>
      if(de.inum == 0)
 248:	db045783          	lhu	a5,-592(s0)
 24c:	d3fd                	beqz	a5,232 <ls+0x17e>
      memmove(p, de.name, DIRSIZ);
 24e:	4639                	li	a2,14
 250:	db240593          	addi	a1,s0,-590
 254:	854e                	mv	a0,s3
 256:	00000097          	auipc	ra,0x0
 25a:	270080e7          	jalr	624(ra) # 4c6 <memmove>
      p[DIRSIZ] = 0;
 25e:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 262:	d9840593          	addi	a1,s0,-616
 266:	dc040513          	addi	a0,s0,-576
 26a:	00000097          	auipc	ra,0x0
 26e:	1cc080e7          	jalr	460(ra) # 436 <stat>
 272:	fa0549e3          	bltz	a0,224 <ls+0x170>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 276:	dc040513          	addi	a0,s0,-576
 27a:	00000097          	auipc	ra,0x0
 27e:	d86080e7          	jalr	-634(ra) # 0 <fmtname>
 282:	85aa                	mv	a1,a0
 284:	da843703          	ld	a4,-600(s0)
 288:	d9c42683          	lw	a3,-612(s0)
 28c:	da041603          	lh	a2,-608(s0)
 290:	8552                	mv	a0,s4
 292:	00000097          	auipc	ra,0x0
 296:	666080e7          	jalr	1638(ra) # 8f8 <printf>
 29a:	bf61                	j	232 <ls+0x17e>

000000000000029c <main>:

int
main(int argc, char *argv[])
{
 29c:	7179                	addi	sp,sp,-48
 29e:	f406                	sd	ra,40(sp)
 2a0:	f022                	sd	s0,32(sp)
 2a2:	ec26                	sd	s1,24(sp)
 2a4:	e84a                	sd	s2,16(sp)
 2a6:	e452                	sd	s4,8(sp)
 2a8:	1800                	addi	s0,sp,48
 2aa:	892a                	mv	s2,a0
 2ac:	8a2e                	mv	s4,a1
  printf("fejklwnfcjkdn\n");
 2ae:	00001517          	auipc	a0,0x1
 2b2:	88250513          	addi	a0,a0,-1918 # b30 <malloc+0x17a>
 2b6:	00000097          	auipc	ra,0x0
 2ba:	642080e7          	jalr	1602(ra) # 8f8 <printf>
  int i;

  if(argc < 2){
 2be:	4785                	li	a5,1
 2c0:	0327d863          	bge	a5,s2,2f0 <main+0x54>
 2c4:	008a0493          	addi	s1,s4,8
 2c8:	3979                	addiw	s2,s2,-2
 2ca:	02091793          	slli	a5,s2,0x20
 2ce:	01d7d913          	srli	s2,a5,0x1d
 2d2:	0a41                	addi	s4,s4,16
 2d4:	9952                	add	s2,s2,s4
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 2d6:	6088                	ld	a0,0(s1)
 2d8:	00000097          	auipc	ra,0x0
 2dc:	ddc080e7          	jalr	-548(ra) # b4 <ls>
  for(i=1; i<argc; i++)
 2e0:	04a1                	addi	s1,s1,8
 2e2:	ff249ae3          	bne	s1,s2,2d6 <main+0x3a>
  exit(0);
 2e6:	4501                	li	a0,0
 2e8:	00000097          	auipc	ra,0x0
 2ec:	290080e7          	jalr	656(ra) # 578 <exit>
    ls(".");
 2f0:	00001517          	auipc	a0,0x1
 2f4:	85050513          	addi	a0,a0,-1968 # b40 <malloc+0x18a>
 2f8:	00000097          	auipc	ra,0x0
 2fc:	dbc080e7          	jalr	-580(ra) # b4 <ls>
    exit(0);
 300:	4501                	li	a0,0
 302:	00000097          	auipc	ra,0x0
 306:	276080e7          	jalr	630(ra) # 578 <exit>

000000000000030a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 30a:	1141                	addi	sp,sp,-16
 30c:	e422                	sd	s0,8(sp)
 30e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 310:	87aa                	mv	a5,a0
 312:	0585                	addi	a1,a1,1
 314:	0785                	addi	a5,a5,1
 316:	fff5c703          	lbu	a4,-1(a1)
 31a:	fee78fa3          	sb	a4,-1(a5)
 31e:	fb75                	bnez	a4,312 <strcpy+0x8>
    ;
  return os;
}
 320:	6422                	ld	s0,8(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret

0000000000000326 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 326:	1141                	addi	sp,sp,-16
 328:	e422                	sd	s0,8(sp)
 32a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 32c:	00054783          	lbu	a5,0(a0)
 330:	cb91                	beqz	a5,344 <strcmp+0x1e>
 332:	0005c703          	lbu	a4,0(a1)
 336:	00f71763          	bne	a4,a5,344 <strcmp+0x1e>
    p++, q++;
 33a:	0505                	addi	a0,a0,1
 33c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 33e:	00054783          	lbu	a5,0(a0)
 342:	fbe5                	bnez	a5,332 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 344:	0005c503          	lbu	a0,0(a1)
}
 348:	40a7853b          	subw	a0,a5,a0
 34c:	6422                	ld	s0,8(sp)
 34e:	0141                	addi	sp,sp,16
 350:	8082                	ret

0000000000000352 <strlen>:

uint
strlen(const char *s)
{
 352:	1141                	addi	sp,sp,-16
 354:	e422                	sd	s0,8(sp)
 356:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 358:	00054783          	lbu	a5,0(a0)
 35c:	cf91                	beqz	a5,378 <strlen+0x26>
 35e:	0505                	addi	a0,a0,1
 360:	87aa                	mv	a5,a0
 362:	4685                	li	a3,1
 364:	9e89                	subw	a3,a3,a0
 366:	00f6853b          	addw	a0,a3,a5
 36a:	0785                	addi	a5,a5,1
 36c:	fff7c703          	lbu	a4,-1(a5)
 370:	fb7d                	bnez	a4,366 <strlen+0x14>
    ;
  return n;
}
 372:	6422                	ld	s0,8(sp)
 374:	0141                	addi	sp,sp,16
 376:	8082                	ret
  for(n = 0; s[n]; n++)
 378:	4501                	li	a0,0
 37a:	bfe5                	j	372 <strlen+0x20>

000000000000037c <memset>:

void*
memset(void *dst, int c, uint n)
{
 37c:	1141                	addi	sp,sp,-16
 37e:	e422                	sd	s0,8(sp)
 380:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 382:	ca19                	beqz	a2,398 <memset+0x1c>
 384:	87aa                	mv	a5,a0
 386:	1602                	slli	a2,a2,0x20
 388:	9201                	srli	a2,a2,0x20
 38a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 38e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 392:	0785                	addi	a5,a5,1
 394:	fee79de3          	bne	a5,a4,38e <memset+0x12>
  }
  return dst;
}
 398:	6422                	ld	s0,8(sp)
 39a:	0141                	addi	sp,sp,16
 39c:	8082                	ret

000000000000039e <strchr>:

char*
strchr(const char *s, char c)
{
 39e:	1141                	addi	sp,sp,-16
 3a0:	e422                	sd	s0,8(sp)
 3a2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3a4:	00054783          	lbu	a5,0(a0)
 3a8:	cb99                	beqz	a5,3be <strchr+0x20>
    if(*s == c)
 3aa:	00f58763          	beq	a1,a5,3b8 <strchr+0x1a>
  for(; *s; s++)
 3ae:	0505                	addi	a0,a0,1
 3b0:	00054783          	lbu	a5,0(a0)
 3b4:	fbfd                	bnez	a5,3aa <strchr+0xc>
      return (char*)s;
  return 0;
 3b6:	4501                	li	a0,0
}
 3b8:	6422                	ld	s0,8(sp)
 3ba:	0141                	addi	sp,sp,16
 3bc:	8082                	ret
  return 0;
 3be:	4501                	li	a0,0
 3c0:	bfe5                	j	3b8 <strchr+0x1a>

00000000000003c2 <gets>:

char*
gets(char *buf, int max)
{
 3c2:	711d                	addi	sp,sp,-96
 3c4:	ec86                	sd	ra,88(sp)
 3c6:	e8a2                	sd	s0,80(sp)
 3c8:	e4a6                	sd	s1,72(sp)
 3ca:	e0ca                	sd	s2,64(sp)
 3cc:	fc4e                	sd	s3,56(sp)
 3ce:	f852                	sd	s4,48(sp)
 3d0:	f456                	sd	s5,40(sp)
 3d2:	f05a                	sd	s6,32(sp)
 3d4:	ec5e                	sd	s7,24(sp)
 3d6:	1080                	addi	s0,sp,96
 3d8:	8baa                	mv	s7,a0
 3da:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3dc:	892a                	mv	s2,a0
 3de:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3e0:	4aa9                	li	s5,10
 3e2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3e4:	89a6                	mv	s3,s1
 3e6:	2485                	addiw	s1,s1,1
 3e8:	0344d863          	bge	s1,s4,418 <gets+0x56>
    cc = read(0, &c, 1);
 3ec:	4605                	li	a2,1
 3ee:	faf40593          	addi	a1,s0,-81
 3f2:	4501                	li	a0,0
 3f4:	00000097          	auipc	ra,0x0
 3f8:	19c080e7          	jalr	412(ra) # 590 <read>
    if(cc < 1)
 3fc:	00a05e63          	blez	a0,418 <gets+0x56>
    buf[i++] = c;
 400:	faf44783          	lbu	a5,-81(s0)
 404:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 408:	01578763          	beq	a5,s5,416 <gets+0x54>
 40c:	0905                	addi	s2,s2,1
 40e:	fd679be3          	bne	a5,s6,3e4 <gets+0x22>
  for(i=0; i+1 < max; ){
 412:	89a6                	mv	s3,s1
 414:	a011                	j	418 <gets+0x56>
 416:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 418:	99de                	add	s3,s3,s7
 41a:	00098023          	sb	zero,0(s3)
  return buf;
}
 41e:	855e                	mv	a0,s7
 420:	60e6                	ld	ra,88(sp)
 422:	6446                	ld	s0,80(sp)
 424:	64a6                	ld	s1,72(sp)
 426:	6906                	ld	s2,64(sp)
 428:	79e2                	ld	s3,56(sp)
 42a:	7a42                	ld	s4,48(sp)
 42c:	7aa2                	ld	s5,40(sp)
 42e:	7b02                	ld	s6,32(sp)
 430:	6be2                	ld	s7,24(sp)
 432:	6125                	addi	sp,sp,96
 434:	8082                	ret

0000000000000436 <stat>:

int
stat(const char *n, struct stat *st)
{
 436:	1101                	addi	sp,sp,-32
 438:	ec06                	sd	ra,24(sp)
 43a:	e822                	sd	s0,16(sp)
 43c:	e426                	sd	s1,8(sp)
 43e:	e04a                	sd	s2,0(sp)
 440:	1000                	addi	s0,sp,32
 442:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 444:	4581                	li	a1,0
 446:	00000097          	auipc	ra,0x0
 44a:	172080e7          	jalr	370(ra) # 5b8 <open>
  if(fd < 0)
 44e:	02054563          	bltz	a0,478 <stat+0x42>
 452:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 454:	85ca                	mv	a1,s2
 456:	00000097          	auipc	ra,0x0
 45a:	17a080e7          	jalr	378(ra) # 5d0 <fstat>
 45e:	892a                	mv	s2,a0
  close(fd);
 460:	8526                	mv	a0,s1
 462:	00000097          	auipc	ra,0x0
 466:	13e080e7          	jalr	318(ra) # 5a0 <close>
  return r;
}
 46a:	854a                	mv	a0,s2
 46c:	60e2                	ld	ra,24(sp)
 46e:	6442                	ld	s0,16(sp)
 470:	64a2                	ld	s1,8(sp)
 472:	6902                	ld	s2,0(sp)
 474:	6105                	addi	sp,sp,32
 476:	8082                	ret
    return -1;
 478:	597d                	li	s2,-1
 47a:	bfc5                	j	46a <stat+0x34>

000000000000047c <atoi>:

int
atoi(const char *s)
{
 47c:	1141                	addi	sp,sp,-16
 47e:	e422                	sd	s0,8(sp)
 480:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 482:	00054603          	lbu	a2,0(a0)
 486:	fd06079b          	addiw	a5,a2,-48
 48a:	0ff7f793          	andi	a5,a5,255
 48e:	4725                	li	a4,9
 490:	02f76963          	bltu	a4,a5,4c2 <atoi+0x46>
 494:	86aa                	mv	a3,a0
  n = 0;
 496:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 498:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 49a:	0685                	addi	a3,a3,1
 49c:	0025179b          	slliw	a5,a0,0x2
 4a0:	9fa9                	addw	a5,a5,a0
 4a2:	0017979b          	slliw	a5,a5,0x1
 4a6:	9fb1                	addw	a5,a5,a2
 4a8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4ac:	0006c603          	lbu	a2,0(a3)
 4b0:	fd06071b          	addiw	a4,a2,-48
 4b4:	0ff77713          	andi	a4,a4,255
 4b8:	fee5f1e3          	bgeu	a1,a4,49a <atoi+0x1e>
  return n;
}
 4bc:	6422                	ld	s0,8(sp)
 4be:	0141                	addi	sp,sp,16
 4c0:	8082                	ret
  n = 0;
 4c2:	4501                	li	a0,0
 4c4:	bfe5                	j	4bc <atoi+0x40>

00000000000004c6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4c6:	1141                	addi	sp,sp,-16
 4c8:	e422                	sd	s0,8(sp)
 4ca:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4cc:	02b57463          	bgeu	a0,a1,4f4 <memmove+0x2e>
    while(n-- > 0)
 4d0:	00c05f63          	blez	a2,4ee <memmove+0x28>
 4d4:	1602                	slli	a2,a2,0x20
 4d6:	9201                	srli	a2,a2,0x20
 4d8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4dc:	872a                	mv	a4,a0
      *dst++ = *src++;
 4de:	0585                	addi	a1,a1,1
 4e0:	0705                	addi	a4,a4,1
 4e2:	fff5c683          	lbu	a3,-1(a1)
 4e6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4ea:	fee79ae3          	bne	a5,a4,4de <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4ee:	6422                	ld	s0,8(sp)
 4f0:	0141                	addi	sp,sp,16
 4f2:	8082                	ret
    dst += n;
 4f4:	00c50733          	add	a4,a0,a2
    src += n;
 4f8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4fa:	fec05ae3          	blez	a2,4ee <memmove+0x28>
 4fe:	fff6079b          	addiw	a5,a2,-1
 502:	1782                	slli	a5,a5,0x20
 504:	9381                	srli	a5,a5,0x20
 506:	fff7c793          	not	a5,a5
 50a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 50c:	15fd                	addi	a1,a1,-1
 50e:	177d                	addi	a4,a4,-1
 510:	0005c683          	lbu	a3,0(a1)
 514:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 518:	fee79ae3          	bne	a5,a4,50c <memmove+0x46>
 51c:	bfc9                	j	4ee <memmove+0x28>

000000000000051e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 51e:	1141                	addi	sp,sp,-16
 520:	e422                	sd	s0,8(sp)
 522:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 524:	ca05                	beqz	a2,554 <memcmp+0x36>
 526:	fff6069b          	addiw	a3,a2,-1
 52a:	1682                	slli	a3,a3,0x20
 52c:	9281                	srli	a3,a3,0x20
 52e:	0685                	addi	a3,a3,1
 530:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 532:	00054783          	lbu	a5,0(a0)
 536:	0005c703          	lbu	a4,0(a1)
 53a:	00e79863          	bne	a5,a4,54a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 53e:	0505                	addi	a0,a0,1
    p2++;
 540:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 542:	fed518e3          	bne	a0,a3,532 <memcmp+0x14>
  }
  return 0;
 546:	4501                	li	a0,0
 548:	a019                	j	54e <memcmp+0x30>
      return *p1 - *p2;
 54a:	40e7853b          	subw	a0,a5,a4
}
 54e:	6422                	ld	s0,8(sp)
 550:	0141                	addi	sp,sp,16
 552:	8082                	ret
  return 0;
 554:	4501                	li	a0,0
 556:	bfe5                	j	54e <memcmp+0x30>

0000000000000558 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 558:	1141                	addi	sp,sp,-16
 55a:	e406                	sd	ra,8(sp)
 55c:	e022                	sd	s0,0(sp)
 55e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 560:	00000097          	auipc	ra,0x0
 564:	f66080e7          	jalr	-154(ra) # 4c6 <memmove>
}
 568:	60a2                	ld	ra,8(sp)
 56a:	6402                	ld	s0,0(sp)
 56c:	0141                	addi	sp,sp,16
 56e:	8082                	ret

0000000000000570 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 570:	4885                	li	a7,1
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <exit>:
.global exit
exit:
 li a7, SYS_exit
 578:	4889                	li	a7,2
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <wait>:
.global wait
wait:
 li a7, SYS_wait
 580:	488d                	li	a7,3
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 588:	4891                	li	a7,4
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <read>:
.global read
read:
 li a7, SYS_read
 590:	4895                	li	a7,5
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <write>:
.global write
write:
 li a7, SYS_write
 598:	48c1                	li	a7,16
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <close>:
.global close
close:
 li a7, SYS_close
 5a0:	48d5                	li	a7,21
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5a8:	4899                	li	a7,6
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5b0:	489d                	li	a7,7
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <open>:
.global open
open:
 li a7, SYS_open
 5b8:	48bd                	li	a7,15
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5c0:	48c5                	li	a7,17
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5c8:	48c9                	li	a7,18
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5d0:	48a1                	li	a7,8
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <link>:
.global link
link:
 li a7, SYS_link
 5d8:	48cd                	li	a7,19
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5e0:	48d1                	li	a7,20
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5e8:	48a5                	li	a7,9
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5f0:	48a9                	li	a7,10
 ecall
 5f2:	00000073          	ecall
 ret
 5f6:	8082                	ret

00000000000005f8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5f8:	48ad                	li	a7,11
 ecall
 5fa:	00000073          	ecall
 ret
 5fe:	8082                	ret

0000000000000600 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 600:	48b1                	li	a7,12
 ecall
 602:	00000073          	ecall
 ret
 606:	8082                	ret

0000000000000608 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 608:	48b5                	li	a7,13
 ecall
 60a:	00000073          	ecall
 ret
 60e:	8082                	ret

0000000000000610 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 610:	48b9                	li	a7,14
 ecall
 612:	00000073          	ecall
 ret
 616:	8082                	ret

0000000000000618 <printmem>:
.global printmem
printmem:
 li a7, SYS_printmem
 618:	48d9                	li	a7,22
 ecall
 61a:	00000073          	ecall
 ret
 61e:	8082                	ret

0000000000000620 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 620:	1101                	addi	sp,sp,-32
 622:	ec06                	sd	ra,24(sp)
 624:	e822                	sd	s0,16(sp)
 626:	1000                	addi	s0,sp,32
 628:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 62c:	4605                	li	a2,1
 62e:	fef40593          	addi	a1,s0,-17
 632:	00000097          	auipc	ra,0x0
 636:	f66080e7          	jalr	-154(ra) # 598 <write>
}
 63a:	60e2                	ld	ra,24(sp)
 63c:	6442                	ld	s0,16(sp)
 63e:	6105                	addi	sp,sp,32
 640:	8082                	ret

0000000000000642 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 642:	7139                	addi	sp,sp,-64
 644:	fc06                	sd	ra,56(sp)
 646:	f822                	sd	s0,48(sp)
 648:	f426                	sd	s1,40(sp)
 64a:	f04a                	sd	s2,32(sp)
 64c:	ec4e                	sd	s3,24(sp)
 64e:	0080                	addi	s0,sp,64
 650:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 652:	c299                	beqz	a3,658 <printint+0x16>
 654:	0805c863          	bltz	a1,6e4 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 658:	2581                	sext.w	a1,a1
  neg = 0;
 65a:	4881                	li	a7,0
 65c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 660:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 662:	2601                	sext.w	a2,a2
 664:	00000517          	auipc	a0,0x0
 668:	4ec50513          	addi	a0,a0,1260 # b50 <digits>
 66c:	883a                	mv	a6,a4
 66e:	2705                	addiw	a4,a4,1
 670:	02c5f7bb          	remuw	a5,a1,a2
 674:	1782                	slli	a5,a5,0x20
 676:	9381                	srli	a5,a5,0x20
 678:	97aa                	add	a5,a5,a0
 67a:	0007c783          	lbu	a5,0(a5)
 67e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 682:	0005879b          	sext.w	a5,a1
 686:	02c5d5bb          	divuw	a1,a1,a2
 68a:	0685                	addi	a3,a3,1
 68c:	fec7f0e3          	bgeu	a5,a2,66c <printint+0x2a>
  if(neg)
 690:	00088b63          	beqz	a7,6a6 <printint+0x64>
    buf[i++] = '-';
 694:	fd040793          	addi	a5,s0,-48
 698:	973e                	add	a4,a4,a5
 69a:	02d00793          	li	a5,45
 69e:	fef70823          	sb	a5,-16(a4)
 6a2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6a6:	02e05863          	blez	a4,6d6 <printint+0x94>
 6aa:	fc040793          	addi	a5,s0,-64
 6ae:	00e78933          	add	s2,a5,a4
 6b2:	fff78993          	addi	s3,a5,-1
 6b6:	99ba                	add	s3,s3,a4
 6b8:	377d                	addiw	a4,a4,-1
 6ba:	1702                	slli	a4,a4,0x20
 6bc:	9301                	srli	a4,a4,0x20
 6be:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6c2:	fff94583          	lbu	a1,-1(s2)
 6c6:	8526                	mv	a0,s1
 6c8:	00000097          	auipc	ra,0x0
 6cc:	f58080e7          	jalr	-168(ra) # 620 <putc>
  while(--i >= 0)
 6d0:	197d                	addi	s2,s2,-1
 6d2:	ff3918e3          	bne	s2,s3,6c2 <printint+0x80>
}
 6d6:	70e2                	ld	ra,56(sp)
 6d8:	7442                	ld	s0,48(sp)
 6da:	74a2                	ld	s1,40(sp)
 6dc:	7902                	ld	s2,32(sp)
 6de:	69e2                	ld	s3,24(sp)
 6e0:	6121                	addi	sp,sp,64
 6e2:	8082                	ret
    x = -xx;
 6e4:	40b005bb          	negw	a1,a1
    neg = 1;
 6e8:	4885                	li	a7,1
    x = -xx;
 6ea:	bf8d                	j	65c <printint+0x1a>

00000000000006ec <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6ec:	7119                	addi	sp,sp,-128
 6ee:	fc86                	sd	ra,120(sp)
 6f0:	f8a2                	sd	s0,112(sp)
 6f2:	f4a6                	sd	s1,104(sp)
 6f4:	f0ca                	sd	s2,96(sp)
 6f6:	ecce                	sd	s3,88(sp)
 6f8:	e8d2                	sd	s4,80(sp)
 6fa:	e4d6                	sd	s5,72(sp)
 6fc:	e0da                	sd	s6,64(sp)
 6fe:	fc5e                	sd	s7,56(sp)
 700:	f862                	sd	s8,48(sp)
 702:	f466                	sd	s9,40(sp)
 704:	f06a                	sd	s10,32(sp)
 706:	ec6e                	sd	s11,24(sp)
 708:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 70a:	0005c903          	lbu	s2,0(a1)
 70e:	18090f63          	beqz	s2,8ac <vprintf+0x1c0>
 712:	8aaa                	mv	s5,a0
 714:	8b32                	mv	s6,a2
 716:	00158493          	addi	s1,a1,1
  state = 0;
 71a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 71c:	02500a13          	li	s4,37
      if(c == 'd'){
 720:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 724:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 728:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 72c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 730:	00000b97          	auipc	s7,0x0
 734:	420b8b93          	addi	s7,s7,1056 # b50 <digits>
 738:	a839                	j	756 <vprintf+0x6a>
        putc(fd, c);
 73a:	85ca                	mv	a1,s2
 73c:	8556                	mv	a0,s5
 73e:	00000097          	auipc	ra,0x0
 742:	ee2080e7          	jalr	-286(ra) # 620 <putc>
 746:	a019                	j	74c <vprintf+0x60>
    } else if(state == '%'){
 748:	01498f63          	beq	s3,s4,766 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 74c:	0485                	addi	s1,s1,1
 74e:	fff4c903          	lbu	s2,-1(s1)
 752:	14090d63          	beqz	s2,8ac <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 756:	0009079b          	sext.w	a5,s2
    if(state == 0){
 75a:	fe0997e3          	bnez	s3,748 <vprintf+0x5c>
      if(c == '%'){
 75e:	fd479ee3          	bne	a5,s4,73a <vprintf+0x4e>
        state = '%';
 762:	89be                	mv	s3,a5
 764:	b7e5                	j	74c <vprintf+0x60>
      if(c == 'd'){
 766:	05878063          	beq	a5,s8,7a6 <vprintf+0xba>
      } else if(c == 'l') {
 76a:	05978c63          	beq	a5,s9,7c2 <vprintf+0xd6>
      } else if(c == 'x') {
 76e:	07a78863          	beq	a5,s10,7de <vprintf+0xf2>
      } else if(c == 'p') {
 772:	09b78463          	beq	a5,s11,7fa <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 776:	07300713          	li	a4,115
 77a:	0ce78663          	beq	a5,a4,846 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 77e:	06300713          	li	a4,99
 782:	0ee78e63          	beq	a5,a4,87e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 786:	11478863          	beq	a5,s4,896 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 78a:	85d2                	mv	a1,s4
 78c:	8556                	mv	a0,s5
 78e:	00000097          	auipc	ra,0x0
 792:	e92080e7          	jalr	-366(ra) # 620 <putc>
        putc(fd, c);
 796:	85ca                	mv	a1,s2
 798:	8556                	mv	a0,s5
 79a:	00000097          	auipc	ra,0x0
 79e:	e86080e7          	jalr	-378(ra) # 620 <putc>
      }
      state = 0;
 7a2:	4981                	li	s3,0
 7a4:	b765                	j	74c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7a6:	008b0913          	addi	s2,s6,8
 7aa:	4685                	li	a3,1
 7ac:	4629                	li	a2,10
 7ae:	000b2583          	lw	a1,0(s6)
 7b2:	8556                	mv	a0,s5
 7b4:	00000097          	auipc	ra,0x0
 7b8:	e8e080e7          	jalr	-370(ra) # 642 <printint>
 7bc:	8b4a                	mv	s6,s2
      state = 0;
 7be:	4981                	li	s3,0
 7c0:	b771                	j	74c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7c2:	008b0913          	addi	s2,s6,8
 7c6:	4681                	li	a3,0
 7c8:	4629                	li	a2,10
 7ca:	000b2583          	lw	a1,0(s6)
 7ce:	8556                	mv	a0,s5
 7d0:	00000097          	auipc	ra,0x0
 7d4:	e72080e7          	jalr	-398(ra) # 642 <printint>
 7d8:	8b4a                	mv	s6,s2
      state = 0;
 7da:	4981                	li	s3,0
 7dc:	bf85                	j	74c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 7de:	008b0913          	addi	s2,s6,8
 7e2:	4681                	li	a3,0
 7e4:	4641                	li	a2,16
 7e6:	000b2583          	lw	a1,0(s6)
 7ea:	8556                	mv	a0,s5
 7ec:	00000097          	auipc	ra,0x0
 7f0:	e56080e7          	jalr	-426(ra) # 642 <printint>
 7f4:	8b4a                	mv	s6,s2
      state = 0;
 7f6:	4981                	li	s3,0
 7f8:	bf91                	j	74c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 7fa:	008b0793          	addi	a5,s6,8
 7fe:	f8f43423          	sd	a5,-120(s0)
 802:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 806:	03000593          	li	a1,48
 80a:	8556                	mv	a0,s5
 80c:	00000097          	auipc	ra,0x0
 810:	e14080e7          	jalr	-492(ra) # 620 <putc>
  putc(fd, 'x');
 814:	85ea                	mv	a1,s10
 816:	8556                	mv	a0,s5
 818:	00000097          	auipc	ra,0x0
 81c:	e08080e7          	jalr	-504(ra) # 620 <putc>
 820:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 822:	03c9d793          	srli	a5,s3,0x3c
 826:	97de                	add	a5,a5,s7
 828:	0007c583          	lbu	a1,0(a5)
 82c:	8556                	mv	a0,s5
 82e:	00000097          	auipc	ra,0x0
 832:	df2080e7          	jalr	-526(ra) # 620 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 836:	0992                	slli	s3,s3,0x4
 838:	397d                	addiw	s2,s2,-1
 83a:	fe0914e3          	bnez	s2,822 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 83e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 842:	4981                	li	s3,0
 844:	b721                	j	74c <vprintf+0x60>
        s = va_arg(ap, char*);
 846:	008b0993          	addi	s3,s6,8
 84a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 84e:	02090163          	beqz	s2,870 <vprintf+0x184>
        while(*s != 0){
 852:	00094583          	lbu	a1,0(s2)
 856:	c9a1                	beqz	a1,8a6 <vprintf+0x1ba>
          putc(fd, *s);
 858:	8556                	mv	a0,s5
 85a:	00000097          	auipc	ra,0x0
 85e:	dc6080e7          	jalr	-570(ra) # 620 <putc>
          s++;
 862:	0905                	addi	s2,s2,1
        while(*s != 0){
 864:	00094583          	lbu	a1,0(s2)
 868:	f9e5                	bnez	a1,858 <vprintf+0x16c>
        s = va_arg(ap, char*);
 86a:	8b4e                	mv	s6,s3
      state = 0;
 86c:	4981                	li	s3,0
 86e:	bdf9                	j	74c <vprintf+0x60>
          s = "(null)";
 870:	00000917          	auipc	s2,0x0
 874:	2d890913          	addi	s2,s2,728 # b48 <malloc+0x192>
        while(*s != 0){
 878:	02800593          	li	a1,40
 87c:	bff1                	j	858 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 87e:	008b0913          	addi	s2,s6,8
 882:	000b4583          	lbu	a1,0(s6)
 886:	8556                	mv	a0,s5
 888:	00000097          	auipc	ra,0x0
 88c:	d98080e7          	jalr	-616(ra) # 620 <putc>
 890:	8b4a                	mv	s6,s2
      state = 0;
 892:	4981                	li	s3,0
 894:	bd65                	j	74c <vprintf+0x60>
        putc(fd, c);
 896:	85d2                	mv	a1,s4
 898:	8556                	mv	a0,s5
 89a:	00000097          	auipc	ra,0x0
 89e:	d86080e7          	jalr	-634(ra) # 620 <putc>
      state = 0;
 8a2:	4981                	li	s3,0
 8a4:	b565                	j	74c <vprintf+0x60>
        s = va_arg(ap, char*);
 8a6:	8b4e                	mv	s6,s3
      state = 0;
 8a8:	4981                	li	s3,0
 8aa:	b54d                	j	74c <vprintf+0x60>
    }
  }
}
 8ac:	70e6                	ld	ra,120(sp)
 8ae:	7446                	ld	s0,112(sp)
 8b0:	74a6                	ld	s1,104(sp)
 8b2:	7906                	ld	s2,96(sp)
 8b4:	69e6                	ld	s3,88(sp)
 8b6:	6a46                	ld	s4,80(sp)
 8b8:	6aa6                	ld	s5,72(sp)
 8ba:	6b06                	ld	s6,64(sp)
 8bc:	7be2                	ld	s7,56(sp)
 8be:	7c42                	ld	s8,48(sp)
 8c0:	7ca2                	ld	s9,40(sp)
 8c2:	7d02                	ld	s10,32(sp)
 8c4:	6de2                	ld	s11,24(sp)
 8c6:	6109                	addi	sp,sp,128
 8c8:	8082                	ret

00000000000008ca <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8ca:	715d                	addi	sp,sp,-80
 8cc:	ec06                	sd	ra,24(sp)
 8ce:	e822                	sd	s0,16(sp)
 8d0:	1000                	addi	s0,sp,32
 8d2:	e010                	sd	a2,0(s0)
 8d4:	e414                	sd	a3,8(s0)
 8d6:	e818                	sd	a4,16(s0)
 8d8:	ec1c                	sd	a5,24(s0)
 8da:	03043023          	sd	a6,32(s0)
 8de:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8e2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8e6:	8622                	mv	a2,s0
 8e8:	00000097          	auipc	ra,0x0
 8ec:	e04080e7          	jalr	-508(ra) # 6ec <vprintf>
}
 8f0:	60e2                	ld	ra,24(sp)
 8f2:	6442                	ld	s0,16(sp)
 8f4:	6161                	addi	sp,sp,80
 8f6:	8082                	ret

00000000000008f8 <printf>:

void
printf(const char *fmt, ...)
{
 8f8:	711d                	addi	sp,sp,-96
 8fa:	ec06                	sd	ra,24(sp)
 8fc:	e822                	sd	s0,16(sp)
 8fe:	1000                	addi	s0,sp,32
 900:	e40c                	sd	a1,8(s0)
 902:	e810                	sd	a2,16(s0)
 904:	ec14                	sd	a3,24(s0)
 906:	f018                	sd	a4,32(s0)
 908:	f41c                	sd	a5,40(s0)
 90a:	03043823          	sd	a6,48(s0)
 90e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 912:	00840613          	addi	a2,s0,8
 916:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 91a:	85aa                	mv	a1,a0
 91c:	4505                	li	a0,1
 91e:	00000097          	auipc	ra,0x0
 922:	dce080e7          	jalr	-562(ra) # 6ec <vprintf>
}
 926:	60e2                	ld	ra,24(sp)
 928:	6442                	ld	s0,16(sp)
 92a:	6125                	addi	sp,sp,96
 92c:	8082                	ret

000000000000092e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 92e:	1141                	addi	sp,sp,-16
 930:	e422                	sd	s0,8(sp)
 932:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 934:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 938:	00000797          	auipc	a5,0x0
 93c:	2307b783          	ld	a5,560(a5) # b68 <freep>
 940:	a805                	j	970 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 942:	4618                	lw	a4,8(a2)
 944:	9db9                	addw	a1,a1,a4
 946:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 94a:	6398                	ld	a4,0(a5)
 94c:	6318                	ld	a4,0(a4)
 94e:	fee53823          	sd	a4,-16(a0)
 952:	a091                	j	996 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 954:	ff852703          	lw	a4,-8(a0)
 958:	9e39                	addw	a2,a2,a4
 95a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 95c:	ff053703          	ld	a4,-16(a0)
 960:	e398                	sd	a4,0(a5)
 962:	a099                	j	9a8 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 964:	6398                	ld	a4,0(a5)
 966:	00e7e463          	bltu	a5,a4,96e <free+0x40>
 96a:	00e6ea63          	bltu	a3,a4,97e <free+0x50>
{
 96e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 970:	fed7fae3          	bgeu	a5,a3,964 <free+0x36>
 974:	6398                	ld	a4,0(a5)
 976:	00e6e463          	bltu	a3,a4,97e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 97a:	fee7eae3          	bltu	a5,a4,96e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 97e:	ff852583          	lw	a1,-8(a0)
 982:	6390                	ld	a2,0(a5)
 984:	02059813          	slli	a6,a1,0x20
 988:	01c85713          	srli	a4,a6,0x1c
 98c:	9736                	add	a4,a4,a3
 98e:	fae60ae3          	beq	a2,a4,942 <free+0x14>
    bp->s.ptr = p->s.ptr;
 992:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 996:	4790                	lw	a2,8(a5)
 998:	02061593          	slli	a1,a2,0x20
 99c:	01c5d713          	srli	a4,a1,0x1c
 9a0:	973e                	add	a4,a4,a5
 9a2:	fae689e3          	beq	a3,a4,954 <free+0x26>
  } else
    p->s.ptr = bp;
 9a6:	e394                	sd	a3,0(a5)
  freep = p;
 9a8:	00000717          	auipc	a4,0x0
 9ac:	1cf73023          	sd	a5,448(a4) # b68 <freep>
}
 9b0:	6422                	ld	s0,8(sp)
 9b2:	0141                	addi	sp,sp,16
 9b4:	8082                	ret

00000000000009b6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9b6:	7139                	addi	sp,sp,-64
 9b8:	fc06                	sd	ra,56(sp)
 9ba:	f822                	sd	s0,48(sp)
 9bc:	f426                	sd	s1,40(sp)
 9be:	f04a                	sd	s2,32(sp)
 9c0:	ec4e                	sd	s3,24(sp)
 9c2:	e852                	sd	s4,16(sp)
 9c4:	e456                	sd	s5,8(sp)
 9c6:	e05a                	sd	s6,0(sp)
 9c8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9ca:	02051493          	slli	s1,a0,0x20
 9ce:	9081                	srli	s1,s1,0x20
 9d0:	04bd                	addi	s1,s1,15
 9d2:	8091                	srli	s1,s1,0x4
 9d4:	0014899b          	addiw	s3,s1,1
 9d8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9da:	00000517          	auipc	a0,0x0
 9de:	18e53503          	ld	a0,398(a0) # b68 <freep>
 9e2:	c515                	beqz	a0,a0e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9e6:	4798                	lw	a4,8(a5)
 9e8:	02977f63          	bgeu	a4,s1,a26 <malloc+0x70>
 9ec:	8a4e                	mv	s4,s3
 9ee:	0009871b          	sext.w	a4,s3
 9f2:	6685                	lui	a3,0x1
 9f4:	00d77363          	bgeu	a4,a3,9fa <malloc+0x44>
 9f8:	6a05                	lui	s4,0x1
 9fa:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9fe:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a02:	00000917          	auipc	s2,0x0
 a06:	16690913          	addi	s2,s2,358 # b68 <freep>
  if(p == (char*)-1)
 a0a:	5afd                	li	s5,-1
 a0c:	a895                	j	a80 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 a0e:	00000797          	auipc	a5,0x0
 a12:	17278793          	addi	a5,a5,370 # b80 <base>
 a16:	00000717          	auipc	a4,0x0
 a1a:	14f73923          	sd	a5,338(a4) # b68 <freep>
 a1e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a20:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a24:	b7e1                	j	9ec <malloc+0x36>
      if(p->s.size == nunits)
 a26:	02e48c63          	beq	s1,a4,a5e <malloc+0xa8>
        p->s.size -= nunits;
 a2a:	4137073b          	subw	a4,a4,s3
 a2e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a30:	02071693          	slli	a3,a4,0x20
 a34:	01c6d713          	srli	a4,a3,0x1c
 a38:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a3a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a3e:	00000717          	auipc	a4,0x0
 a42:	12a73523          	sd	a0,298(a4) # b68 <freep>
      return (void*)(p + 1);
 a46:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a4a:	70e2                	ld	ra,56(sp)
 a4c:	7442                	ld	s0,48(sp)
 a4e:	74a2                	ld	s1,40(sp)
 a50:	7902                	ld	s2,32(sp)
 a52:	69e2                	ld	s3,24(sp)
 a54:	6a42                	ld	s4,16(sp)
 a56:	6aa2                	ld	s5,8(sp)
 a58:	6b02                	ld	s6,0(sp)
 a5a:	6121                	addi	sp,sp,64
 a5c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a5e:	6398                	ld	a4,0(a5)
 a60:	e118                	sd	a4,0(a0)
 a62:	bff1                	j	a3e <malloc+0x88>
  hp->s.size = nu;
 a64:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a68:	0541                	addi	a0,a0,16
 a6a:	00000097          	auipc	ra,0x0
 a6e:	ec4080e7          	jalr	-316(ra) # 92e <free>
  return freep;
 a72:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a76:	d971                	beqz	a0,a4a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a78:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a7a:	4798                	lw	a4,8(a5)
 a7c:	fa9775e3          	bgeu	a4,s1,a26 <malloc+0x70>
    if(p == freep)
 a80:	00093703          	ld	a4,0(s2)
 a84:	853e                	mv	a0,a5
 a86:	fef719e3          	bne	a4,a5,a78 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 a8a:	8552                	mv	a0,s4
 a8c:	00000097          	auipc	ra,0x0
 a90:	b74080e7          	jalr	-1164(ra) # 600 <sbrk>
  if(p == (char*)-1)
 a94:	fd5518e3          	bne	a0,s5,a64 <malloc+0xae>
        return 0;
 a98:	4501                	li	a0,0
 a9a:	bf45                	j	a4a <malloc+0x94>
