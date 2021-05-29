
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	slli	a0,a0,0x1f
      10:	00005097          	auipc	ra,0x5
      14:	710080e7          	jalr	1808(ra) # 5720 <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00005097          	auipc	ra,0x5
      26:	6fe080e7          	jalr	1790(ra) # 5720 <open>
    uint64 addr = addrs[ai];
      2a:	55fd                	li	a1,-1
    if(fd >= 0){
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1);
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00006517          	auipc	a0,0x6
      42:	ef250513          	addi	a0,a0,-270 # 5f30 <malloc+0x41a>
      46:	00006097          	auipc	ra,0x6
      4a:	a12080e7          	jalr	-1518(ra) # 5a58 <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00005097          	auipc	ra,0x5
      54:	690080e7          	jalr	1680(ra) # 56e0 <exit>

0000000000000058 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      58:	00009797          	auipc	a5,0x9
      5c:	46878793          	addi	a5,a5,1128 # 94c0 <uninit>
      60:	0000c697          	auipc	a3,0xc
      64:	b7068693          	addi	a3,a3,-1168 # bbd0 <buf>
    if(uninit[i] != '\0'){
      68:	0007c703          	lbu	a4,0(a5)
      6c:	e709                	bnez	a4,76 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      6e:	0785                	addi	a5,a5,1
      70:	fed79ce3          	bne	a5,a3,68 <bsstest+0x10>
      74:	8082                	ret
{
      76:	1141                	addi	sp,sp,-16
      78:	e406                	sd	ra,8(sp)
      7a:	e022                	sd	s0,0(sp)
      7c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      7e:	85aa                	mv	a1,a0
      80:	00006517          	auipc	a0,0x6
      84:	ed050513          	addi	a0,a0,-304 # 5f50 <malloc+0x43a>
      88:	00006097          	auipc	ra,0x6
      8c:	9d0080e7          	jalr	-1584(ra) # 5a58 <printf>
      exit(1);
      90:	4505                	li	a0,1
      92:	00005097          	auipc	ra,0x5
      96:	64e080e7          	jalr	1614(ra) # 56e0 <exit>

000000000000009a <opentest>:
{
      9a:	1101                	addi	sp,sp,-32
      9c:	ec06                	sd	ra,24(sp)
      9e:	e822                	sd	s0,16(sp)
      a0:	e426                	sd	s1,8(sp)
      a2:	1000                	addi	s0,sp,32
      a4:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      a6:	4581                	li	a1,0
      a8:	00006517          	auipc	a0,0x6
      ac:	ec050513          	addi	a0,a0,-320 # 5f68 <malloc+0x452>
      b0:	00005097          	auipc	ra,0x5
      b4:	670080e7          	jalr	1648(ra) # 5720 <open>
  if(fd < 0){
      b8:	02054663          	bltz	a0,e4 <opentest+0x4a>
  close(fd);
      bc:	00005097          	auipc	ra,0x5
      c0:	64c080e7          	jalr	1612(ra) # 5708 <close>
  fd = open("doesnotexist", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
      ca:	ec250513          	addi	a0,a0,-318 # 5f88 <malloc+0x472>
      ce:	00005097          	auipc	ra,0x5
      d2:	652080e7          	jalr	1618(ra) # 5720 <open>
  if(fd >= 0){
      d6:	02055563          	bgez	a0,100 <opentest+0x66>
}
      da:	60e2                	ld	ra,24(sp)
      dc:	6442                	ld	s0,16(sp)
      de:	64a2                	ld	s1,8(sp)
      e0:	6105                	addi	sp,sp,32
      e2:	8082                	ret
    printf("%s: open echo failed!\n", s);
      e4:	85a6                	mv	a1,s1
      e6:	00006517          	auipc	a0,0x6
      ea:	e8a50513          	addi	a0,a0,-374 # 5f70 <malloc+0x45a>
      ee:	00006097          	auipc	ra,0x6
      f2:	96a080e7          	jalr	-1686(ra) # 5a58 <printf>
    exit(1);
      f6:	4505                	li	a0,1
      f8:	00005097          	auipc	ra,0x5
      fc:	5e8080e7          	jalr	1512(ra) # 56e0 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     100:	85a6                	mv	a1,s1
     102:	00006517          	auipc	a0,0x6
     106:	e9650513          	addi	a0,a0,-362 # 5f98 <malloc+0x482>
     10a:	00006097          	auipc	ra,0x6
     10e:	94e080e7          	jalr	-1714(ra) # 5a58 <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	00005097          	auipc	ra,0x5
     118:	5cc080e7          	jalr	1484(ra) # 56e0 <exit>

000000000000011c <truncate2>:
{
     11c:	7179                	addi	sp,sp,-48
     11e:	f406                	sd	ra,40(sp)
     120:	f022                	sd	s0,32(sp)
     122:	ec26                	sd	s1,24(sp)
     124:	e84a                	sd	s2,16(sp)
     126:	e44e                	sd	s3,8(sp)
     128:	1800                	addi	s0,sp,48
     12a:	89aa                	mv	s3,a0
  unlink("truncfile");
     12c:	00006517          	auipc	a0,0x6
     130:	e9450513          	addi	a0,a0,-364 # 5fc0 <malloc+0x4aa>
     134:	00005097          	auipc	ra,0x5
     138:	5fc080e7          	jalr	1532(ra) # 5730 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13c:	60100593          	li	a1,1537
     140:	00006517          	auipc	a0,0x6
     144:	e8050513          	addi	a0,a0,-384 # 5fc0 <malloc+0x4aa>
     148:	00005097          	auipc	ra,0x5
     14c:	5d8080e7          	jalr	1496(ra) # 5720 <open>
     150:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     152:	4611                	li	a2,4
     154:	00006597          	auipc	a1,0x6
     158:	e7c58593          	addi	a1,a1,-388 # 5fd0 <malloc+0x4ba>
     15c:	00005097          	auipc	ra,0x5
     160:	5a4080e7          	jalr	1444(ra) # 5700 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     164:	40100593          	li	a1,1025
     168:	00006517          	auipc	a0,0x6
     16c:	e5850513          	addi	a0,a0,-424 # 5fc0 <malloc+0x4aa>
     170:	00005097          	auipc	ra,0x5
     174:	5b0080e7          	jalr	1456(ra) # 5720 <open>
     178:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     17a:	4605                	li	a2,1
     17c:	00006597          	auipc	a1,0x6
     180:	e5c58593          	addi	a1,a1,-420 # 5fd8 <malloc+0x4c2>
     184:	8526                	mv	a0,s1
     186:	00005097          	auipc	ra,0x5
     18a:	57a080e7          	jalr	1402(ra) # 5700 <write>
  if(n != -1){
     18e:	57fd                	li	a5,-1
     190:	02f51b63          	bne	a0,a5,1c6 <truncate2+0xaa>
  unlink("truncfile");
     194:	00006517          	auipc	a0,0x6
     198:	e2c50513          	addi	a0,a0,-468 # 5fc0 <malloc+0x4aa>
     19c:	00005097          	auipc	ra,0x5
     1a0:	594080e7          	jalr	1428(ra) # 5730 <unlink>
  close(fd1);
     1a4:	8526                	mv	a0,s1
     1a6:	00005097          	auipc	ra,0x5
     1aa:	562080e7          	jalr	1378(ra) # 5708 <close>
  close(fd2);
     1ae:	854a                	mv	a0,s2
     1b0:	00005097          	auipc	ra,0x5
     1b4:	558080e7          	jalr	1368(ra) # 5708 <close>
}
     1b8:	70a2                	ld	ra,40(sp)
     1ba:	7402                	ld	s0,32(sp)
     1bc:	64e2                	ld	s1,24(sp)
     1be:	6942                	ld	s2,16(sp)
     1c0:	69a2                	ld	s3,8(sp)
     1c2:	6145                	addi	sp,sp,48
     1c4:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1c6:	862a                	mv	a2,a0
     1c8:	85ce                	mv	a1,s3
     1ca:	00006517          	auipc	a0,0x6
     1ce:	e1650513          	addi	a0,a0,-490 # 5fe0 <malloc+0x4ca>
     1d2:	00006097          	auipc	ra,0x6
     1d6:	886080e7          	jalr	-1914(ra) # 5a58 <printf>
    exit(1);
     1da:	4505                	li	a0,1
     1dc:	00005097          	auipc	ra,0x5
     1e0:	504080e7          	jalr	1284(ra) # 56e0 <exit>

00000000000001e4 <createtest>:
{
     1e4:	7179                	addi	sp,sp,-48
     1e6:	f406                	sd	ra,40(sp)
     1e8:	f022                	sd	s0,32(sp)
     1ea:	ec26                	sd	s1,24(sp)
     1ec:	e84a                	sd	s2,16(sp)
     1ee:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1f0:	06100793          	li	a5,97
     1f4:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1f8:	fc040d23          	sb	zero,-38(s0)
     1fc:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     200:	06400913          	li	s2,100
    name[1] = '0' + i;
     204:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
     208:	20200593          	li	a1,514
     20c:	fd840513          	addi	a0,s0,-40
     210:	00005097          	auipc	ra,0x5
     214:	510080e7          	jalr	1296(ra) # 5720 <open>
    close(fd);
     218:	00005097          	auipc	ra,0x5
     21c:	4f0080e7          	jalr	1264(ra) # 5708 <close>
  for(i = 0; i < N; i++){
     220:	2485                	addiw	s1,s1,1
     222:	0ff4f493          	andi	s1,s1,255
     226:	fd249fe3          	bne	s1,s2,204 <createtest+0x20>
  name[0] = 'a';
     22a:	06100793          	li	a5,97
     22e:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     232:	fc040d23          	sb	zero,-38(s0)
     236:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     23a:	06400913          	li	s2,100
    name[1] = '0' + i;
     23e:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     242:	fd840513          	addi	a0,s0,-40
     246:	00005097          	auipc	ra,0x5
     24a:	4ea080e7          	jalr	1258(ra) # 5730 <unlink>
  for(i = 0; i < N; i++){
     24e:	2485                	addiw	s1,s1,1
     250:	0ff4f493          	andi	s1,s1,255
     254:	ff2495e3          	bne	s1,s2,23e <createtest+0x5a>
}
     258:	70a2                	ld	ra,40(sp)
     25a:	7402                	ld	s0,32(sp)
     25c:	64e2                	ld	s1,24(sp)
     25e:	6942                	ld	s2,16(sp)
     260:	6145                	addi	sp,sp,48
     262:	8082                	ret

0000000000000264 <bigwrite>:
{
     264:	715d                	addi	sp,sp,-80
     266:	e486                	sd	ra,72(sp)
     268:	e0a2                	sd	s0,64(sp)
     26a:	fc26                	sd	s1,56(sp)
     26c:	f84a                	sd	s2,48(sp)
     26e:	f44e                	sd	s3,40(sp)
     270:	f052                	sd	s4,32(sp)
     272:	ec56                	sd	s5,24(sp)
     274:	e85a                	sd	s6,16(sp)
     276:	e45e                	sd	s7,8(sp)
     278:	0880                	addi	s0,sp,80
     27a:	8baa                	mv	s7,a0
  unlink("bigwrite");
     27c:	00006517          	auipc	a0,0x6
     280:	b5450513          	addi	a0,a0,-1196 # 5dd0 <malloc+0x2ba>
     284:	00005097          	auipc	ra,0x5
     288:	4ac080e7          	jalr	1196(ra) # 5730 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     28c:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     290:	00006a97          	auipc	s5,0x6
     294:	b40a8a93          	addi	s5,s5,-1216 # 5dd0 <malloc+0x2ba>
      int cc = write(fd, buf, sz);
     298:	0000ca17          	auipc	s4,0xc
     29c:	938a0a13          	addi	s4,s4,-1736 # bbd0 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a0:	6b0d                	lui	s6,0x3
     2a2:	1c9b0b13          	addi	s6,s6,457 # 31c9 <subdir+0x173>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a6:	20200593          	li	a1,514
     2aa:	8556                	mv	a0,s5
     2ac:	00005097          	auipc	ra,0x5
     2b0:	474080e7          	jalr	1140(ra) # 5720 <open>
     2b4:	892a                	mv	s2,a0
    if(fd < 0){
     2b6:	04054d63          	bltz	a0,310 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2ba:	8626                	mv	a2,s1
     2bc:	85d2                	mv	a1,s4
     2be:	00005097          	auipc	ra,0x5
     2c2:	442080e7          	jalr	1090(ra) # 5700 <write>
     2c6:	89aa                	mv	s3,a0
      if(cc != sz){
     2c8:	06a49463          	bne	s1,a0,330 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2cc:	8626                	mv	a2,s1
     2ce:	85d2                	mv	a1,s4
     2d0:	854a                	mv	a0,s2
     2d2:	00005097          	auipc	ra,0x5
     2d6:	42e080e7          	jalr	1070(ra) # 5700 <write>
      if(cc != sz){
     2da:	04951963          	bne	a0,s1,32c <bigwrite+0xc8>
    close(fd);
     2de:	854a                	mv	a0,s2
     2e0:	00005097          	auipc	ra,0x5
     2e4:	428080e7          	jalr	1064(ra) # 5708 <close>
    unlink("bigwrite");
     2e8:	8556                	mv	a0,s5
     2ea:	00005097          	auipc	ra,0x5
     2ee:	446080e7          	jalr	1094(ra) # 5730 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2f2:	1d74849b          	addiw	s1,s1,471
     2f6:	fb6498e3          	bne	s1,s6,2a6 <bigwrite+0x42>
}
     2fa:	60a6                	ld	ra,72(sp)
     2fc:	6406                	ld	s0,64(sp)
     2fe:	74e2                	ld	s1,56(sp)
     300:	7942                	ld	s2,48(sp)
     302:	79a2                	ld	s3,40(sp)
     304:	7a02                	ld	s4,32(sp)
     306:	6ae2                	ld	s5,24(sp)
     308:	6b42                	ld	s6,16(sp)
     30a:	6ba2                	ld	s7,8(sp)
     30c:	6161                	addi	sp,sp,80
     30e:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     310:	85de                	mv	a1,s7
     312:	00006517          	auipc	a0,0x6
     316:	cf650513          	addi	a0,a0,-778 # 6008 <malloc+0x4f2>
     31a:	00005097          	auipc	ra,0x5
     31e:	73e080e7          	jalr	1854(ra) # 5a58 <printf>
      exit(1);
     322:	4505                	li	a0,1
     324:	00005097          	auipc	ra,0x5
     328:	3bc080e7          	jalr	956(ra) # 56e0 <exit>
     32c:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     32e:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     330:	86ce                	mv	a3,s3
     332:	8626                	mv	a2,s1
     334:	85de                	mv	a1,s7
     336:	00006517          	auipc	a0,0x6
     33a:	cf250513          	addi	a0,a0,-782 # 6028 <malloc+0x512>
     33e:	00005097          	auipc	ra,0x5
     342:	71a080e7          	jalr	1818(ra) # 5a58 <printf>
        exit(1);
     346:	4505                	li	a0,1
     348:	00005097          	auipc	ra,0x5
     34c:	398080e7          	jalr	920(ra) # 56e0 <exit>

0000000000000350 <copyin>:
{
     350:	715d                	addi	sp,sp,-80
     352:	e486                	sd	ra,72(sp)
     354:	e0a2                	sd	s0,64(sp)
     356:	fc26                	sd	s1,56(sp)
     358:	f84a                	sd	s2,48(sp)
     35a:	f44e                	sd	s3,40(sp)
     35c:	f052                	sd	s4,32(sp)
     35e:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     360:	4785                	li	a5,1
     362:	07fe                	slli	a5,a5,0x1f
     364:	fcf43023          	sd	a5,-64(s0)
     368:	57fd                	li	a5,-1
     36a:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     36e:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     372:	00006a17          	auipc	s4,0x6
     376:	ccea0a13          	addi	s4,s4,-818 # 6040 <malloc+0x52a>
    uint64 addr = addrs[ai];
     37a:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     37e:	20100593          	li	a1,513
     382:	8552                	mv	a0,s4
     384:	00005097          	auipc	ra,0x5
     388:	39c080e7          	jalr	924(ra) # 5720 <open>
     38c:	84aa                	mv	s1,a0
    if(fd < 0){
     38e:	08054863          	bltz	a0,41e <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     392:	6609                	lui	a2,0x2
     394:	85ce                	mv	a1,s3
     396:	00005097          	auipc	ra,0x5
     39a:	36a080e7          	jalr	874(ra) # 5700 <write>
    if(n >= 0){
     39e:	08055d63          	bgez	a0,438 <copyin+0xe8>
    close(fd);
     3a2:	8526                	mv	a0,s1
     3a4:	00005097          	auipc	ra,0x5
     3a8:	364080e7          	jalr	868(ra) # 5708 <close>
    unlink("copyin1");
     3ac:	8552                	mv	a0,s4
     3ae:	00005097          	auipc	ra,0x5
     3b2:	382080e7          	jalr	898(ra) # 5730 <unlink>
    n = write(1, (char*)addr, 8192);
     3b6:	6609                	lui	a2,0x2
     3b8:	85ce                	mv	a1,s3
     3ba:	4505                	li	a0,1
     3bc:	00005097          	auipc	ra,0x5
     3c0:	344080e7          	jalr	836(ra) # 5700 <write>
    if(n > 0){
     3c4:	08a04963          	bgtz	a0,456 <copyin+0x106>
    if(pipe(fds) < 0){
     3c8:	fb840513          	addi	a0,s0,-72
     3cc:	00005097          	auipc	ra,0x5
     3d0:	324080e7          	jalr	804(ra) # 56f0 <pipe>
     3d4:	0a054063          	bltz	a0,474 <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     3d8:	6609                	lui	a2,0x2
     3da:	85ce                	mv	a1,s3
     3dc:	fbc42503          	lw	a0,-68(s0)
     3e0:	00005097          	auipc	ra,0x5
     3e4:	320080e7          	jalr	800(ra) # 5700 <write>
    if(n > 0){
     3e8:	0aa04363          	bgtz	a0,48e <copyin+0x13e>
    close(fds[0]);
     3ec:	fb842503          	lw	a0,-72(s0)
     3f0:	00005097          	auipc	ra,0x5
     3f4:	318080e7          	jalr	792(ra) # 5708 <close>
    close(fds[1]);
     3f8:	fbc42503          	lw	a0,-68(s0)
     3fc:	00005097          	auipc	ra,0x5
     400:	30c080e7          	jalr	780(ra) # 5708 <close>
  for(int ai = 0; ai < 2; ai++){
     404:	0921                	addi	s2,s2,8
     406:	fd040793          	addi	a5,s0,-48
     40a:	f6f918e3          	bne	s2,a5,37a <copyin+0x2a>
}
     40e:	60a6                	ld	ra,72(sp)
     410:	6406                	ld	s0,64(sp)
     412:	74e2                	ld	s1,56(sp)
     414:	7942                	ld	s2,48(sp)
     416:	79a2                	ld	s3,40(sp)
     418:	7a02                	ld	s4,32(sp)
     41a:	6161                	addi	sp,sp,80
     41c:	8082                	ret
      printf("open(copyin1) failed\n");
     41e:	00006517          	auipc	a0,0x6
     422:	c2a50513          	addi	a0,a0,-982 # 6048 <malloc+0x532>
     426:	00005097          	auipc	ra,0x5
     42a:	632080e7          	jalr	1586(ra) # 5a58 <printf>
      exit(1);
     42e:	4505                	li	a0,1
     430:	00005097          	auipc	ra,0x5
     434:	2b0080e7          	jalr	688(ra) # 56e0 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     438:	862a                	mv	a2,a0
     43a:	85ce                	mv	a1,s3
     43c:	00006517          	auipc	a0,0x6
     440:	c2450513          	addi	a0,a0,-988 # 6060 <malloc+0x54a>
     444:	00005097          	auipc	ra,0x5
     448:	614080e7          	jalr	1556(ra) # 5a58 <printf>
      exit(1);
     44c:	4505                	li	a0,1
     44e:	00005097          	auipc	ra,0x5
     452:	292080e7          	jalr	658(ra) # 56e0 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     456:	862a                	mv	a2,a0
     458:	85ce                	mv	a1,s3
     45a:	00006517          	auipc	a0,0x6
     45e:	c3650513          	addi	a0,a0,-970 # 6090 <malloc+0x57a>
     462:	00005097          	auipc	ra,0x5
     466:	5f6080e7          	jalr	1526(ra) # 5a58 <printf>
      exit(1);
     46a:	4505                	li	a0,1
     46c:	00005097          	auipc	ra,0x5
     470:	274080e7          	jalr	628(ra) # 56e0 <exit>
      printf("pipe() failed\n");
     474:	00006517          	auipc	a0,0x6
     478:	c4c50513          	addi	a0,a0,-948 # 60c0 <malloc+0x5aa>
     47c:	00005097          	auipc	ra,0x5
     480:	5dc080e7          	jalr	1500(ra) # 5a58 <printf>
      exit(1);
     484:	4505                	li	a0,1
     486:	00005097          	auipc	ra,0x5
     48a:	25a080e7          	jalr	602(ra) # 56e0 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     48e:	862a                	mv	a2,a0
     490:	85ce                	mv	a1,s3
     492:	00006517          	auipc	a0,0x6
     496:	c3e50513          	addi	a0,a0,-962 # 60d0 <malloc+0x5ba>
     49a:	00005097          	auipc	ra,0x5
     49e:	5be080e7          	jalr	1470(ra) # 5a58 <printf>
      exit(1);
     4a2:	4505                	li	a0,1
     4a4:	00005097          	auipc	ra,0x5
     4a8:	23c080e7          	jalr	572(ra) # 56e0 <exit>

00000000000004ac <copyout>:
{
     4ac:	711d                	addi	sp,sp,-96
     4ae:	ec86                	sd	ra,88(sp)
     4b0:	e8a2                	sd	s0,80(sp)
     4b2:	e4a6                	sd	s1,72(sp)
     4b4:	e0ca                	sd	s2,64(sp)
     4b6:	fc4e                	sd	s3,56(sp)
     4b8:	f852                	sd	s4,48(sp)
     4ba:	f456                	sd	s5,40(sp)
     4bc:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     4be:	4785                	li	a5,1
     4c0:	07fe                	slli	a5,a5,0x1f
     4c2:	faf43823          	sd	a5,-80(s0)
     4c6:	57fd                	li	a5,-1
     4c8:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     4cc:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     4d0:	00006a17          	auipc	s4,0x6
     4d4:	c30a0a13          	addi	s4,s4,-976 # 6100 <malloc+0x5ea>
    n = write(fds[1], "x", 1);
     4d8:	00006a97          	auipc	s5,0x6
     4dc:	b00a8a93          	addi	s5,s5,-1280 # 5fd8 <malloc+0x4c2>
    uint64 addr = addrs[ai];
     4e0:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     4e4:	4581                	li	a1,0
     4e6:	8552                	mv	a0,s4
     4e8:	00005097          	auipc	ra,0x5
     4ec:	238080e7          	jalr	568(ra) # 5720 <open>
     4f0:	84aa                	mv	s1,a0
    if(fd < 0){
     4f2:	08054663          	bltz	a0,57e <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     4f6:	6609                	lui	a2,0x2
     4f8:	85ce                	mv	a1,s3
     4fa:	00005097          	auipc	ra,0x5
     4fe:	1fe080e7          	jalr	510(ra) # 56f8 <read>
    if(n > 0){
     502:	08a04b63          	bgtz	a0,598 <copyout+0xec>
    close(fd);
     506:	8526                	mv	a0,s1
     508:	00005097          	auipc	ra,0x5
     50c:	200080e7          	jalr	512(ra) # 5708 <close>
    if(pipe(fds) < 0){
     510:	fa840513          	addi	a0,s0,-88
     514:	00005097          	auipc	ra,0x5
     518:	1dc080e7          	jalr	476(ra) # 56f0 <pipe>
     51c:	08054d63          	bltz	a0,5b6 <copyout+0x10a>
    n = write(fds[1], "x", 1);
     520:	4605                	li	a2,1
     522:	85d6                	mv	a1,s5
     524:	fac42503          	lw	a0,-84(s0)
     528:	00005097          	auipc	ra,0x5
     52c:	1d8080e7          	jalr	472(ra) # 5700 <write>
    if(n != 1){
     530:	4785                	li	a5,1
     532:	08f51f63          	bne	a0,a5,5d0 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     536:	6609                	lui	a2,0x2
     538:	85ce                	mv	a1,s3
     53a:	fa842503          	lw	a0,-88(s0)
     53e:	00005097          	auipc	ra,0x5
     542:	1ba080e7          	jalr	442(ra) # 56f8 <read>
    if(n > 0){
     546:	0aa04263          	bgtz	a0,5ea <copyout+0x13e>
    close(fds[0]);
     54a:	fa842503          	lw	a0,-88(s0)
     54e:	00005097          	auipc	ra,0x5
     552:	1ba080e7          	jalr	442(ra) # 5708 <close>
    close(fds[1]);
     556:	fac42503          	lw	a0,-84(s0)
     55a:	00005097          	auipc	ra,0x5
     55e:	1ae080e7          	jalr	430(ra) # 5708 <close>
  for(int ai = 0; ai < 2; ai++){
     562:	0921                	addi	s2,s2,8
     564:	fc040793          	addi	a5,s0,-64
     568:	f6f91ce3          	bne	s2,a5,4e0 <copyout+0x34>
}
     56c:	60e6                	ld	ra,88(sp)
     56e:	6446                	ld	s0,80(sp)
     570:	64a6                	ld	s1,72(sp)
     572:	6906                	ld	s2,64(sp)
     574:	79e2                	ld	s3,56(sp)
     576:	7a42                	ld	s4,48(sp)
     578:	7aa2                	ld	s5,40(sp)
     57a:	6125                	addi	sp,sp,96
     57c:	8082                	ret
      printf("open(README) failed\n");
     57e:	00006517          	auipc	a0,0x6
     582:	b8a50513          	addi	a0,a0,-1142 # 6108 <malloc+0x5f2>
     586:	00005097          	auipc	ra,0x5
     58a:	4d2080e7          	jalr	1234(ra) # 5a58 <printf>
      exit(1);
     58e:	4505                	li	a0,1
     590:	00005097          	auipc	ra,0x5
     594:	150080e7          	jalr	336(ra) # 56e0 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     598:	862a                	mv	a2,a0
     59a:	85ce                	mv	a1,s3
     59c:	00006517          	auipc	a0,0x6
     5a0:	b8450513          	addi	a0,a0,-1148 # 6120 <malloc+0x60a>
     5a4:	00005097          	auipc	ra,0x5
     5a8:	4b4080e7          	jalr	1204(ra) # 5a58 <printf>
      exit(1);
     5ac:	4505                	li	a0,1
     5ae:	00005097          	auipc	ra,0x5
     5b2:	132080e7          	jalr	306(ra) # 56e0 <exit>
      printf("pipe() failed\n");
     5b6:	00006517          	auipc	a0,0x6
     5ba:	b0a50513          	addi	a0,a0,-1270 # 60c0 <malloc+0x5aa>
     5be:	00005097          	auipc	ra,0x5
     5c2:	49a080e7          	jalr	1178(ra) # 5a58 <printf>
      exit(1);
     5c6:	4505                	li	a0,1
     5c8:	00005097          	auipc	ra,0x5
     5cc:	118080e7          	jalr	280(ra) # 56e0 <exit>
      printf("pipe write failed\n");
     5d0:	00006517          	auipc	a0,0x6
     5d4:	b8050513          	addi	a0,a0,-1152 # 6150 <malloc+0x63a>
     5d8:	00005097          	auipc	ra,0x5
     5dc:	480080e7          	jalr	1152(ra) # 5a58 <printf>
      exit(1);
     5e0:	4505                	li	a0,1
     5e2:	00005097          	auipc	ra,0x5
     5e6:	0fe080e7          	jalr	254(ra) # 56e0 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5ea:	862a                	mv	a2,a0
     5ec:	85ce                	mv	a1,s3
     5ee:	00006517          	auipc	a0,0x6
     5f2:	b7a50513          	addi	a0,a0,-1158 # 6168 <malloc+0x652>
     5f6:	00005097          	auipc	ra,0x5
     5fa:	462080e7          	jalr	1122(ra) # 5a58 <printf>
      exit(1);
     5fe:	4505                	li	a0,1
     600:	00005097          	auipc	ra,0x5
     604:	0e0080e7          	jalr	224(ra) # 56e0 <exit>

0000000000000608 <truncate1>:
{
     608:	711d                	addi	sp,sp,-96
     60a:	ec86                	sd	ra,88(sp)
     60c:	e8a2                	sd	s0,80(sp)
     60e:	e4a6                	sd	s1,72(sp)
     610:	e0ca                	sd	s2,64(sp)
     612:	fc4e                	sd	s3,56(sp)
     614:	f852                	sd	s4,48(sp)
     616:	f456                	sd	s5,40(sp)
     618:	1080                	addi	s0,sp,96
     61a:	8aaa                	mv	s5,a0
  unlink("truncfile");
     61c:	00006517          	auipc	a0,0x6
     620:	9a450513          	addi	a0,a0,-1628 # 5fc0 <malloc+0x4aa>
     624:	00005097          	auipc	ra,0x5
     628:	10c080e7          	jalr	268(ra) # 5730 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     62c:	60100593          	li	a1,1537
     630:	00006517          	auipc	a0,0x6
     634:	99050513          	addi	a0,a0,-1648 # 5fc0 <malloc+0x4aa>
     638:	00005097          	auipc	ra,0x5
     63c:	0e8080e7          	jalr	232(ra) # 5720 <open>
     640:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     642:	4611                	li	a2,4
     644:	00006597          	auipc	a1,0x6
     648:	98c58593          	addi	a1,a1,-1652 # 5fd0 <malloc+0x4ba>
     64c:	00005097          	auipc	ra,0x5
     650:	0b4080e7          	jalr	180(ra) # 5700 <write>
  close(fd1);
     654:	8526                	mv	a0,s1
     656:	00005097          	auipc	ra,0x5
     65a:	0b2080e7          	jalr	178(ra) # 5708 <close>
  int fd2 = open("truncfile", O_RDONLY);
     65e:	4581                	li	a1,0
     660:	00006517          	auipc	a0,0x6
     664:	96050513          	addi	a0,a0,-1696 # 5fc0 <malloc+0x4aa>
     668:	00005097          	auipc	ra,0x5
     66c:	0b8080e7          	jalr	184(ra) # 5720 <open>
     670:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     672:	02000613          	li	a2,32
     676:	fa040593          	addi	a1,s0,-96
     67a:	00005097          	auipc	ra,0x5
     67e:	07e080e7          	jalr	126(ra) # 56f8 <read>
  if(n != 4){
     682:	4791                	li	a5,4
     684:	0cf51e63          	bne	a0,a5,760 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     688:	40100593          	li	a1,1025
     68c:	00006517          	auipc	a0,0x6
     690:	93450513          	addi	a0,a0,-1740 # 5fc0 <malloc+0x4aa>
     694:	00005097          	auipc	ra,0x5
     698:	08c080e7          	jalr	140(ra) # 5720 <open>
     69c:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     69e:	4581                	li	a1,0
     6a0:	00006517          	auipc	a0,0x6
     6a4:	92050513          	addi	a0,a0,-1760 # 5fc0 <malloc+0x4aa>
     6a8:	00005097          	auipc	ra,0x5
     6ac:	078080e7          	jalr	120(ra) # 5720 <open>
     6b0:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     6b2:	02000613          	li	a2,32
     6b6:	fa040593          	addi	a1,s0,-96
     6ba:	00005097          	auipc	ra,0x5
     6be:	03e080e7          	jalr	62(ra) # 56f8 <read>
     6c2:	8a2a                	mv	s4,a0
  if(n != 0){
     6c4:	ed4d                	bnez	a0,77e <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     6c6:	02000613          	li	a2,32
     6ca:	fa040593          	addi	a1,s0,-96
     6ce:	8526                	mv	a0,s1
     6d0:	00005097          	auipc	ra,0x5
     6d4:	028080e7          	jalr	40(ra) # 56f8 <read>
     6d8:	8a2a                	mv	s4,a0
  if(n != 0){
     6da:	e971                	bnez	a0,7ae <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     6dc:	4619                	li	a2,6
     6de:	00006597          	auipc	a1,0x6
     6e2:	b1a58593          	addi	a1,a1,-1254 # 61f8 <malloc+0x6e2>
     6e6:	854e                	mv	a0,s3
     6e8:	00005097          	auipc	ra,0x5
     6ec:	018080e7          	jalr	24(ra) # 5700 <write>
  n = read(fd3, buf, sizeof(buf));
     6f0:	02000613          	li	a2,32
     6f4:	fa040593          	addi	a1,s0,-96
     6f8:	854a                	mv	a0,s2
     6fa:	00005097          	auipc	ra,0x5
     6fe:	ffe080e7          	jalr	-2(ra) # 56f8 <read>
  if(n != 6){
     702:	4799                	li	a5,6
     704:	0cf51d63          	bne	a0,a5,7de <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     708:	02000613          	li	a2,32
     70c:	fa040593          	addi	a1,s0,-96
     710:	8526                	mv	a0,s1
     712:	00005097          	auipc	ra,0x5
     716:	fe6080e7          	jalr	-26(ra) # 56f8 <read>
  if(n != 2){
     71a:	4789                	li	a5,2
     71c:	0ef51063          	bne	a0,a5,7fc <truncate1+0x1f4>
  unlink("truncfile");
     720:	00006517          	auipc	a0,0x6
     724:	8a050513          	addi	a0,a0,-1888 # 5fc0 <malloc+0x4aa>
     728:	00005097          	auipc	ra,0x5
     72c:	008080e7          	jalr	8(ra) # 5730 <unlink>
  close(fd1);
     730:	854e                	mv	a0,s3
     732:	00005097          	auipc	ra,0x5
     736:	fd6080e7          	jalr	-42(ra) # 5708 <close>
  close(fd2);
     73a:	8526                	mv	a0,s1
     73c:	00005097          	auipc	ra,0x5
     740:	fcc080e7          	jalr	-52(ra) # 5708 <close>
  close(fd3);
     744:	854a                	mv	a0,s2
     746:	00005097          	auipc	ra,0x5
     74a:	fc2080e7          	jalr	-62(ra) # 5708 <close>
}
     74e:	60e6                	ld	ra,88(sp)
     750:	6446                	ld	s0,80(sp)
     752:	64a6                	ld	s1,72(sp)
     754:	6906                	ld	s2,64(sp)
     756:	79e2                	ld	s3,56(sp)
     758:	7a42                	ld	s4,48(sp)
     75a:	7aa2                	ld	s5,40(sp)
     75c:	6125                	addi	sp,sp,96
     75e:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     760:	862a                	mv	a2,a0
     762:	85d6                	mv	a1,s5
     764:	00006517          	auipc	a0,0x6
     768:	a3450513          	addi	a0,a0,-1484 # 6198 <malloc+0x682>
     76c:	00005097          	auipc	ra,0x5
     770:	2ec080e7          	jalr	748(ra) # 5a58 <printf>
    exit(1);
     774:	4505                	li	a0,1
     776:	00005097          	auipc	ra,0x5
     77a:	f6a080e7          	jalr	-150(ra) # 56e0 <exit>
    printf("aaa fd3=%d\n", fd3);
     77e:	85ca                	mv	a1,s2
     780:	00006517          	auipc	a0,0x6
     784:	a3850513          	addi	a0,a0,-1480 # 61b8 <malloc+0x6a2>
     788:	00005097          	auipc	ra,0x5
     78c:	2d0080e7          	jalr	720(ra) # 5a58 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     790:	8652                	mv	a2,s4
     792:	85d6                	mv	a1,s5
     794:	00006517          	auipc	a0,0x6
     798:	a3450513          	addi	a0,a0,-1484 # 61c8 <malloc+0x6b2>
     79c:	00005097          	auipc	ra,0x5
     7a0:	2bc080e7          	jalr	700(ra) # 5a58 <printf>
    exit(1);
     7a4:	4505                	li	a0,1
     7a6:	00005097          	auipc	ra,0x5
     7aa:	f3a080e7          	jalr	-198(ra) # 56e0 <exit>
    printf("bbb fd2=%d\n", fd2);
     7ae:	85a6                	mv	a1,s1
     7b0:	00006517          	auipc	a0,0x6
     7b4:	a3850513          	addi	a0,a0,-1480 # 61e8 <malloc+0x6d2>
     7b8:	00005097          	auipc	ra,0x5
     7bc:	2a0080e7          	jalr	672(ra) # 5a58 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7c0:	8652                	mv	a2,s4
     7c2:	85d6                	mv	a1,s5
     7c4:	00006517          	auipc	a0,0x6
     7c8:	a0450513          	addi	a0,a0,-1532 # 61c8 <malloc+0x6b2>
     7cc:	00005097          	auipc	ra,0x5
     7d0:	28c080e7          	jalr	652(ra) # 5a58 <printf>
    exit(1);
     7d4:	4505                	li	a0,1
     7d6:	00005097          	auipc	ra,0x5
     7da:	f0a080e7          	jalr	-246(ra) # 56e0 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     7de:	862a                	mv	a2,a0
     7e0:	85d6                	mv	a1,s5
     7e2:	00006517          	auipc	a0,0x6
     7e6:	a1e50513          	addi	a0,a0,-1506 # 6200 <malloc+0x6ea>
     7ea:	00005097          	auipc	ra,0x5
     7ee:	26e080e7          	jalr	622(ra) # 5a58 <printf>
    exit(1);
     7f2:	4505                	li	a0,1
     7f4:	00005097          	auipc	ra,0x5
     7f8:	eec080e7          	jalr	-276(ra) # 56e0 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     7fc:	862a                	mv	a2,a0
     7fe:	85d6                	mv	a1,s5
     800:	00006517          	auipc	a0,0x6
     804:	a2050513          	addi	a0,a0,-1504 # 6220 <malloc+0x70a>
     808:	00005097          	auipc	ra,0x5
     80c:	250080e7          	jalr	592(ra) # 5a58 <printf>
    exit(1);
     810:	4505                	li	a0,1
     812:	00005097          	auipc	ra,0x5
     816:	ece080e7          	jalr	-306(ra) # 56e0 <exit>

000000000000081a <writetest>:
{
     81a:	7139                	addi	sp,sp,-64
     81c:	fc06                	sd	ra,56(sp)
     81e:	f822                	sd	s0,48(sp)
     820:	f426                	sd	s1,40(sp)
     822:	f04a                	sd	s2,32(sp)
     824:	ec4e                	sd	s3,24(sp)
     826:	e852                	sd	s4,16(sp)
     828:	e456                	sd	s5,8(sp)
     82a:	e05a                	sd	s6,0(sp)
     82c:	0080                	addi	s0,sp,64
     82e:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     830:	20200593          	li	a1,514
     834:	00006517          	auipc	a0,0x6
     838:	a0c50513          	addi	a0,a0,-1524 # 6240 <malloc+0x72a>
     83c:	00005097          	auipc	ra,0x5
     840:	ee4080e7          	jalr	-284(ra) # 5720 <open>
  if(fd < 0){
     844:	0a054d63          	bltz	a0,8fe <writetest+0xe4>
     848:	892a                	mv	s2,a0
     84a:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     84c:	00006997          	auipc	s3,0x6
     850:	a1c98993          	addi	s3,s3,-1508 # 6268 <malloc+0x752>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     854:	00006a97          	auipc	s5,0x6
     858:	a4ca8a93          	addi	s5,s5,-1460 # 62a0 <malloc+0x78a>
  for(i = 0; i < N; i++){
     85c:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     860:	4629                	li	a2,10
     862:	85ce                	mv	a1,s3
     864:	854a                	mv	a0,s2
     866:	00005097          	auipc	ra,0x5
     86a:	e9a080e7          	jalr	-358(ra) # 5700 <write>
     86e:	47a9                	li	a5,10
     870:	0af51563          	bne	a0,a5,91a <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     874:	4629                	li	a2,10
     876:	85d6                	mv	a1,s5
     878:	854a                	mv	a0,s2
     87a:	00005097          	auipc	ra,0x5
     87e:	e86080e7          	jalr	-378(ra) # 5700 <write>
     882:	47a9                	li	a5,10
     884:	0af51a63          	bne	a0,a5,938 <writetest+0x11e>
  for(i = 0; i < N; i++){
     888:	2485                	addiw	s1,s1,1
     88a:	fd449be3          	bne	s1,s4,860 <writetest+0x46>
  close(fd);
     88e:	854a                	mv	a0,s2
     890:	00005097          	auipc	ra,0x5
     894:	e78080e7          	jalr	-392(ra) # 5708 <close>
  fd = open("small", O_RDONLY);
     898:	4581                	li	a1,0
     89a:	00006517          	auipc	a0,0x6
     89e:	9a650513          	addi	a0,a0,-1626 # 6240 <malloc+0x72a>
     8a2:	00005097          	auipc	ra,0x5
     8a6:	e7e080e7          	jalr	-386(ra) # 5720 <open>
     8aa:	84aa                	mv	s1,a0
  if(fd < 0){
     8ac:	0a054563          	bltz	a0,956 <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     8b0:	7d000613          	li	a2,2000
     8b4:	0000b597          	auipc	a1,0xb
     8b8:	31c58593          	addi	a1,a1,796 # bbd0 <buf>
     8bc:	00005097          	auipc	ra,0x5
     8c0:	e3c080e7          	jalr	-452(ra) # 56f8 <read>
  if(i != N*SZ*2){
     8c4:	7d000793          	li	a5,2000
     8c8:	0af51563          	bne	a0,a5,972 <writetest+0x158>
  close(fd);
     8cc:	8526                	mv	a0,s1
     8ce:	00005097          	auipc	ra,0x5
     8d2:	e3a080e7          	jalr	-454(ra) # 5708 <close>
  if(unlink("small") < 0){
     8d6:	00006517          	auipc	a0,0x6
     8da:	96a50513          	addi	a0,a0,-1686 # 6240 <malloc+0x72a>
     8de:	00005097          	auipc	ra,0x5
     8e2:	e52080e7          	jalr	-430(ra) # 5730 <unlink>
     8e6:	0a054463          	bltz	a0,98e <writetest+0x174>
}
     8ea:	70e2                	ld	ra,56(sp)
     8ec:	7442                	ld	s0,48(sp)
     8ee:	74a2                	ld	s1,40(sp)
     8f0:	7902                	ld	s2,32(sp)
     8f2:	69e2                	ld	s3,24(sp)
     8f4:	6a42                	ld	s4,16(sp)
     8f6:	6aa2                	ld	s5,8(sp)
     8f8:	6b02                	ld	s6,0(sp)
     8fa:	6121                	addi	sp,sp,64
     8fc:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     8fe:	85da                	mv	a1,s6
     900:	00006517          	auipc	a0,0x6
     904:	94850513          	addi	a0,a0,-1720 # 6248 <malloc+0x732>
     908:	00005097          	auipc	ra,0x5
     90c:	150080e7          	jalr	336(ra) # 5a58 <printf>
    exit(1);
     910:	4505                	li	a0,1
     912:	00005097          	auipc	ra,0x5
     916:	dce080e7          	jalr	-562(ra) # 56e0 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     91a:	8626                	mv	a2,s1
     91c:	85da                	mv	a1,s6
     91e:	00006517          	auipc	a0,0x6
     922:	95a50513          	addi	a0,a0,-1702 # 6278 <malloc+0x762>
     926:	00005097          	auipc	ra,0x5
     92a:	132080e7          	jalr	306(ra) # 5a58 <printf>
      exit(1);
     92e:	4505                	li	a0,1
     930:	00005097          	auipc	ra,0x5
     934:	db0080e7          	jalr	-592(ra) # 56e0 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     938:	8626                	mv	a2,s1
     93a:	85da                	mv	a1,s6
     93c:	00006517          	auipc	a0,0x6
     940:	97450513          	addi	a0,a0,-1676 # 62b0 <malloc+0x79a>
     944:	00005097          	auipc	ra,0x5
     948:	114080e7          	jalr	276(ra) # 5a58 <printf>
      exit(1);
     94c:	4505                	li	a0,1
     94e:	00005097          	auipc	ra,0x5
     952:	d92080e7          	jalr	-622(ra) # 56e0 <exit>
    printf("%s: error: open small failed!\n", s);
     956:	85da                	mv	a1,s6
     958:	00006517          	auipc	a0,0x6
     95c:	98050513          	addi	a0,a0,-1664 # 62d8 <malloc+0x7c2>
     960:	00005097          	auipc	ra,0x5
     964:	0f8080e7          	jalr	248(ra) # 5a58 <printf>
    exit(1);
     968:	4505                	li	a0,1
     96a:	00005097          	auipc	ra,0x5
     96e:	d76080e7          	jalr	-650(ra) # 56e0 <exit>
    printf("%s: read failed\n", s);
     972:	85da                	mv	a1,s6
     974:	00006517          	auipc	a0,0x6
     978:	98450513          	addi	a0,a0,-1660 # 62f8 <malloc+0x7e2>
     97c:	00005097          	auipc	ra,0x5
     980:	0dc080e7          	jalr	220(ra) # 5a58 <printf>
    exit(1);
     984:	4505                	li	a0,1
     986:	00005097          	auipc	ra,0x5
     98a:	d5a080e7          	jalr	-678(ra) # 56e0 <exit>
    printf("%s: unlink small failed\n", s);
     98e:	85da                	mv	a1,s6
     990:	00006517          	auipc	a0,0x6
     994:	98050513          	addi	a0,a0,-1664 # 6310 <malloc+0x7fa>
     998:	00005097          	auipc	ra,0x5
     99c:	0c0080e7          	jalr	192(ra) # 5a58 <printf>
    exit(1);
     9a0:	4505                	li	a0,1
     9a2:	00005097          	auipc	ra,0x5
     9a6:	d3e080e7          	jalr	-706(ra) # 56e0 <exit>

00000000000009aa <writebig>:
{
     9aa:	7139                	addi	sp,sp,-64
     9ac:	fc06                	sd	ra,56(sp)
     9ae:	f822                	sd	s0,48(sp)
     9b0:	f426                	sd	s1,40(sp)
     9b2:	f04a                	sd	s2,32(sp)
     9b4:	ec4e                	sd	s3,24(sp)
     9b6:	e852                	sd	s4,16(sp)
     9b8:	e456                	sd	s5,8(sp)
     9ba:	0080                	addi	s0,sp,64
     9bc:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     9be:	20200593          	li	a1,514
     9c2:	00006517          	auipc	a0,0x6
     9c6:	96e50513          	addi	a0,a0,-1682 # 6330 <malloc+0x81a>
     9ca:	00005097          	auipc	ra,0x5
     9ce:	d56080e7          	jalr	-682(ra) # 5720 <open>
     9d2:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     9d4:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     9d6:	0000b917          	auipc	s2,0xb
     9da:	1fa90913          	addi	s2,s2,506 # bbd0 <buf>
  for(i = 0; i < MAXFILE; i++){
     9de:	10c00a13          	li	s4,268
  if(fd < 0){
     9e2:	06054c63          	bltz	a0,a5a <writebig+0xb0>
    ((int*)buf)[0] = i;
     9e6:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     9ea:	40000613          	li	a2,1024
     9ee:	85ca                	mv	a1,s2
     9f0:	854e                	mv	a0,s3
     9f2:	00005097          	auipc	ra,0x5
     9f6:	d0e080e7          	jalr	-754(ra) # 5700 <write>
     9fa:	40000793          	li	a5,1024
     9fe:	06f51c63          	bne	a0,a5,a76 <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     a02:	2485                	addiw	s1,s1,1
     a04:	ff4491e3          	bne	s1,s4,9e6 <writebig+0x3c>
  close(fd);
     a08:	854e                	mv	a0,s3
     a0a:	00005097          	auipc	ra,0x5
     a0e:	cfe080e7          	jalr	-770(ra) # 5708 <close>
  fd = open("big", O_RDONLY);
     a12:	4581                	li	a1,0
     a14:	00006517          	auipc	a0,0x6
     a18:	91c50513          	addi	a0,a0,-1764 # 6330 <malloc+0x81a>
     a1c:	00005097          	auipc	ra,0x5
     a20:	d04080e7          	jalr	-764(ra) # 5720 <open>
     a24:	89aa                	mv	s3,a0
  n = 0;
     a26:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a28:	0000b917          	auipc	s2,0xb
     a2c:	1a890913          	addi	s2,s2,424 # bbd0 <buf>
  if(fd < 0){
     a30:	06054263          	bltz	a0,a94 <writebig+0xea>
    i = read(fd, buf, BSIZE);
     a34:	40000613          	li	a2,1024
     a38:	85ca                	mv	a1,s2
     a3a:	854e                	mv	a0,s3
     a3c:	00005097          	auipc	ra,0x5
     a40:	cbc080e7          	jalr	-836(ra) # 56f8 <read>
    if(i == 0){
     a44:	c535                	beqz	a0,ab0 <writebig+0x106>
    } else if(i != BSIZE){
     a46:	40000793          	li	a5,1024
     a4a:	0af51f63          	bne	a0,a5,b08 <writebig+0x15e>
    if(((int*)buf)[0] != n){
     a4e:	00092683          	lw	a3,0(s2)
     a52:	0c969a63          	bne	a3,s1,b26 <writebig+0x17c>
    n++;
     a56:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a58:	bff1                	j	a34 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     a5a:	85d6                	mv	a1,s5
     a5c:	00006517          	auipc	a0,0x6
     a60:	8dc50513          	addi	a0,a0,-1828 # 6338 <malloc+0x822>
     a64:	00005097          	auipc	ra,0x5
     a68:	ff4080e7          	jalr	-12(ra) # 5a58 <printf>
    exit(1);
     a6c:	4505                	li	a0,1
     a6e:	00005097          	auipc	ra,0x5
     a72:	c72080e7          	jalr	-910(ra) # 56e0 <exit>
      printf("%s: error: write big file failed\n", s, i);
     a76:	8626                	mv	a2,s1
     a78:	85d6                	mv	a1,s5
     a7a:	00006517          	auipc	a0,0x6
     a7e:	8de50513          	addi	a0,a0,-1826 # 6358 <malloc+0x842>
     a82:	00005097          	auipc	ra,0x5
     a86:	fd6080e7          	jalr	-42(ra) # 5a58 <printf>
      exit(1);
     a8a:	4505                	li	a0,1
     a8c:	00005097          	auipc	ra,0x5
     a90:	c54080e7          	jalr	-940(ra) # 56e0 <exit>
    printf("%s: error: open big failed!\n", s);
     a94:	85d6                	mv	a1,s5
     a96:	00006517          	auipc	a0,0x6
     a9a:	8ea50513          	addi	a0,a0,-1814 # 6380 <malloc+0x86a>
     a9e:	00005097          	auipc	ra,0x5
     aa2:	fba080e7          	jalr	-70(ra) # 5a58 <printf>
    exit(1);
     aa6:	4505                	li	a0,1
     aa8:	00005097          	auipc	ra,0x5
     aac:	c38080e7          	jalr	-968(ra) # 56e0 <exit>
      if(n == MAXFILE - 1){
     ab0:	10b00793          	li	a5,267
     ab4:	02f48a63          	beq	s1,a5,ae8 <writebig+0x13e>
  close(fd);
     ab8:	854e                	mv	a0,s3
     aba:	00005097          	auipc	ra,0x5
     abe:	c4e080e7          	jalr	-946(ra) # 5708 <close>
  if(unlink("big") < 0){
     ac2:	00006517          	auipc	a0,0x6
     ac6:	86e50513          	addi	a0,a0,-1938 # 6330 <malloc+0x81a>
     aca:	00005097          	auipc	ra,0x5
     ace:	c66080e7          	jalr	-922(ra) # 5730 <unlink>
     ad2:	06054963          	bltz	a0,b44 <writebig+0x19a>
}
     ad6:	70e2                	ld	ra,56(sp)
     ad8:	7442                	ld	s0,48(sp)
     ada:	74a2                	ld	s1,40(sp)
     adc:	7902                	ld	s2,32(sp)
     ade:	69e2                	ld	s3,24(sp)
     ae0:	6a42                	ld	s4,16(sp)
     ae2:	6aa2                	ld	s5,8(sp)
     ae4:	6121                	addi	sp,sp,64
     ae6:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     ae8:	10b00613          	li	a2,267
     aec:	85d6                	mv	a1,s5
     aee:	00006517          	auipc	a0,0x6
     af2:	8b250513          	addi	a0,a0,-1870 # 63a0 <malloc+0x88a>
     af6:	00005097          	auipc	ra,0x5
     afa:	f62080e7          	jalr	-158(ra) # 5a58 <printf>
        exit(1);
     afe:	4505                	li	a0,1
     b00:	00005097          	auipc	ra,0x5
     b04:	be0080e7          	jalr	-1056(ra) # 56e0 <exit>
      printf("%s: read failed %d\n", s, i);
     b08:	862a                	mv	a2,a0
     b0a:	85d6                	mv	a1,s5
     b0c:	00006517          	auipc	a0,0x6
     b10:	8bc50513          	addi	a0,a0,-1860 # 63c8 <malloc+0x8b2>
     b14:	00005097          	auipc	ra,0x5
     b18:	f44080e7          	jalr	-188(ra) # 5a58 <printf>
      exit(1);
     b1c:	4505                	li	a0,1
     b1e:	00005097          	auipc	ra,0x5
     b22:	bc2080e7          	jalr	-1086(ra) # 56e0 <exit>
      printf("%s: read content of block %d is %d\n", s,
     b26:	8626                	mv	a2,s1
     b28:	85d6                	mv	a1,s5
     b2a:	00006517          	auipc	a0,0x6
     b2e:	8b650513          	addi	a0,a0,-1866 # 63e0 <malloc+0x8ca>
     b32:	00005097          	auipc	ra,0x5
     b36:	f26080e7          	jalr	-218(ra) # 5a58 <printf>
      exit(1);
     b3a:	4505                	li	a0,1
     b3c:	00005097          	auipc	ra,0x5
     b40:	ba4080e7          	jalr	-1116(ra) # 56e0 <exit>
    printf("%s: unlink big failed\n", s);
     b44:	85d6                	mv	a1,s5
     b46:	00006517          	auipc	a0,0x6
     b4a:	8c250513          	addi	a0,a0,-1854 # 6408 <malloc+0x8f2>
     b4e:	00005097          	auipc	ra,0x5
     b52:	f0a080e7          	jalr	-246(ra) # 5a58 <printf>
    exit(1);
     b56:	4505                	li	a0,1
     b58:	00005097          	auipc	ra,0x5
     b5c:	b88080e7          	jalr	-1144(ra) # 56e0 <exit>

0000000000000b60 <unlinkread>:
{
     b60:	7179                	addi	sp,sp,-48
     b62:	f406                	sd	ra,40(sp)
     b64:	f022                	sd	s0,32(sp)
     b66:	ec26                	sd	s1,24(sp)
     b68:	e84a                	sd	s2,16(sp)
     b6a:	e44e                	sd	s3,8(sp)
     b6c:	1800                	addi	s0,sp,48
     b6e:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b70:	20200593          	li	a1,514
     b74:	00005517          	auipc	a0,0x5
     b78:	1ec50513          	addi	a0,a0,492 # 5d60 <malloc+0x24a>
     b7c:	00005097          	auipc	ra,0x5
     b80:	ba4080e7          	jalr	-1116(ra) # 5720 <open>
  if(fd < 0){
     b84:	0e054563          	bltz	a0,c6e <unlinkread+0x10e>
     b88:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b8a:	4615                	li	a2,5
     b8c:	00006597          	auipc	a1,0x6
     b90:	8b458593          	addi	a1,a1,-1868 # 6440 <malloc+0x92a>
     b94:	00005097          	auipc	ra,0x5
     b98:	b6c080e7          	jalr	-1172(ra) # 5700 <write>
  close(fd);
     b9c:	8526                	mv	a0,s1
     b9e:	00005097          	auipc	ra,0x5
     ba2:	b6a080e7          	jalr	-1174(ra) # 5708 <close>
  fd = open("unlinkread", O_RDWR);
     ba6:	4589                	li	a1,2
     ba8:	00005517          	auipc	a0,0x5
     bac:	1b850513          	addi	a0,a0,440 # 5d60 <malloc+0x24a>
     bb0:	00005097          	auipc	ra,0x5
     bb4:	b70080e7          	jalr	-1168(ra) # 5720 <open>
     bb8:	84aa                	mv	s1,a0
  if(fd < 0){
     bba:	0c054863          	bltz	a0,c8a <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     bbe:	00005517          	auipc	a0,0x5
     bc2:	1a250513          	addi	a0,a0,418 # 5d60 <malloc+0x24a>
     bc6:	00005097          	auipc	ra,0x5
     bca:	b6a080e7          	jalr	-1174(ra) # 5730 <unlink>
     bce:	ed61                	bnez	a0,ca6 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     bd0:	20200593          	li	a1,514
     bd4:	00005517          	auipc	a0,0x5
     bd8:	18c50513          	addi	a0,a0,396 # 5d60 <malloc+0x24a>
     bdc:	00005097          	auipc	ra,0x5
     be0:	b44080e7          	jalr	-1212(ra) # 5720 <open>
     be4:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     be6:	460d                	li	a2,3
     be8:	00006597          	auipc	a1,0x6
     bec:	8a058593          	addi	a1,a1,-1888 # 6488 <malloc+0x972>
     bf0:	00005097          	auipc	ra,0x5
     bf4:	b10080e7          	jalr	-1264(ra) # 5700 <write>
  close(fd1);
     bf8:	854a                	mv	a0,s2
     bfa:	00005097          	auipc	ra,0x5
     bfe:	b0e080e7          	jalr	-1266(ra) # 5708 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     c02:	660d                	lui	a2,0x3
     c04:	0000b597          	auipc	a1,0xb
     c08:	fcc58593          	addi	a1,a1,-52 # bbd0 <buf>
     c0c:	8526                	mv	a0,s1
     c0e:	00005097          	auipc	ra,0x5
     c12:	aea080e7          	jalr	-1302(ra) # 56f8 <read>
     c16:	4795                	li	a5,5
     c18:	0af51563          	bne	a0,a5,cc2 <unlinkread+0x162>
  if(buf[0] != 'h'){
     c1c:	0000b717          	auipc	a4,0xb
     c20:	fb474703          	lbu	a4,-76(a4) # bbd0 <buf>
     c24:	06800793          	li	a5,104
     c28:	0af71b63          	bne	a4,a5,cde <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     c2c:	4629                	li	a2,10
     c2e:	0000b597          	auipc	a1,0xb
     c32:	fa258593          	addi	a1,a1,-94 # bbd0 <buf>
     c36:	8526                	mv	a0,s1
     c38:	00005097          	auipc	ra,0x5
     c3c:	ac8080e7          	jalr	-1336(ra) # 5700 <write>
     c40:	47a9                	li	a5,10
     c42:	0af51c63          	bne	a0,a5,cfa <unlinkread+0x19a>
  close(fd);
     c46:	8526                	mv	a0,s1
     c48:	00005097          	auipc	ra,0x5
     c4c:	ac0080e7          	jalr	-1344(ra) # 5708 <close>
  unlink("unlinkread");
     c50:	00005517          	auipc	a0,0x5
     c54:	11050513          	addi	a0,a0,272 # 5d60 <malloc+0x24a>
     c58:	00005097          	auipc	ra,0x5
     c5c:	ad8080e7          	jalr	-1320(ra) # 5730 <unlink>
}
     c60:	70a2                	ld	ra,40(sp)
     c62:	7402                	ld	s0,32(sp)
     c64:	64e2                	ld	s1,24(sp)
     c66:	6942                	ld	s2,16(sp)
     c68:	69a2                	ld	s3,8(sp)
     c6a:	6145                	addi	sp,sp,48
     c6c:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     c6e:	85ce                	mv	a1,s3
     c70:	00005517          	auipc	a0,0x5
     c74:	7b050513          	addi	a0,a0,1968 # 6420 <malloc+0x90a>
     c78:	00005097          	auipc	ra,0x5
     c7c:	de0080e7          	jalr	-544(ra) # 5a58 <printf>
    exit(1);
     c80:	4505                	li	a0,1
     c82:	00005097          	auipc	ra,0x5
     c86:	a5e080e7          	jalr	-1442(ra) # 56e0 <exit>
    printf("%s: open unlinkread failed\n", s);
     c8a:	85ce                	mv	a1,s3
     c8c:	00005517          	auipc	a0,0x5
     c90:	7bc50513          	addi	a0,a0,1980 # 6448 <malloc+0x932>
     c94:	00005097          	auipc	ra,0x5
     c98:	dc4080e7          	jalr	-572(ra) # 5a58 <printf>
    exit(1);
     c9c:	4505                	li	a0,1
     c9e:	00005097          	auipc	ra,0x5
     ca2:	a42080e7          	jalr	-1470(ra) # 56e0 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     ca6:	85ce                	mv	a1,s3
     ca8:	00005517          	auipc	a0,0x5
     cac:	7c050513          	addi	a0,a0,1984 # 6468 <malloc+0x952>
     cb0:	00005097          	auipc	ra,0x5
     cb4:	da8080e7          	jalr	-600(ra) # 5a58 <printf>
    exit(1);
     cb8:	4505                	li	a0,1
     cba:	00005097          	auipc	ra,0x5
     cbe:	a26080e7          	jalr	-1498(ra) # 56e0 <exit>
    printf("%s: unlinkread read failed", s);
     cc2:	85ce                	mv	a1,s3
     cc4:	00005517          	auipc	a0,0x5
     cc8:	7cc50513          	addi	a0,a0,1996 # 6490 <malloc+0x97a>
     ccc:	00005097          	auipc	ra,0x5
     cd0:	d8c080e7          	jalr	-628(ra) # 5a58 <printf>
    exit(1);
     cd4:	4505                	li	a0,1
     cd6:	00005097          	auipc	ra,0x5
     cda:	a0a080e7          	jalr	-1526(ra) # 56e0 <exit>
    printf("%s: unlinkread wrong data\n", s);
     cde:	85ce                	mv	a1,s3
     ce0:	00005517          	auipc	a0,0x5
     ce4:	7d050513          	addi	a0,a0,2000 # 64b0 <malloc+0x99a>
     ce8:	00005097          	auipc	ra,0x5
     cec:	d70080e7          	jalr	-656(ra) # 5a58 <printf>
    exit(1);
     cf0:	4505                	li	a0,1
     cf2:	00005097          	auipc	ra,0x5
     cf6:	9ee080e7          	jalr	-1554(ra) # 56e0 <exit>
    printf("%s: unlinkread write failed\n", s);
     cfa:	85ce                	mv	a1,s3
     cfc:	00005517          	auipc	a0,0x5
     d00:	7d450513          	addi	a0,a0,2004 # 64d0 <malloc+0x9ba>
     d04:	00005097          	auipc	ra,0x5
     d08:	d54080e7          	jalr	-684(ra) # 5a58 <printf>
    exit(1);
     d0c:	4505                	li	a0,1
     d0e:	00005097          	auipc	ra,0x5
     d12:	9d2080e7          	jalr	-1582(ra) # 56e0 <exit>

0000000000000d16 <linktest>:
{
     d16:	1101                	addi	sp,sp,-32
     d18:	ec06                	sd	ra,24(sp)
     d1a:	e822                	sd	s0,16(sp)
     d1c:	e426                	sd	s1,8(sp)
     d1e:	e04a                	sd	s2,0(sp)
     d20:	1000                	addi	s0,sp,32
     d22:	892a                	mv	s2,a0
  unlink("lf1");
     d24:	00005517          	auipc	a0,0x5
     d28:	7cc50513          	addi	a0,a0,1996 # 64f0 <malloc+0x9da>
     d2c:	00005097          	auipc	ra,0x5
     d30:	a04080e7          	jalr	-1532(ra) # 5730 <unlink>
  unlink("lf2");
     d34:	00005517          	auipc	a0,0x5
     d38:	7c450513          	addi	a0,a0,1988 # 64f8 <malloc+0x9e2>
     d3c:	00005097          	auipc	ra,0x5
     d40:	9f4080e7          	jalr	-1548(ra) # 5730 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     d44:	20200593          	li	a1,514
     d48:	00005517          	auipc	a0,0x5
     d4c:	7a850513          	addi	a0,a0,1960 # 64f0 <malloc+0x9da>
     d50:	00005097          	auipc	ra,0x5
     d54:	9d0080e7          	jalr	-1584(ra) # 5720 <open>
  if(fd < 0){
     d58:	10054763          	bltz	a0,e66 <linktest+0x150>
     d5c:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     d5e:	4615                	li	a2,5
     d60:	00005597          	auipc	a1,0x5
     d64:	6e058593          	addi	a1,a1,1760 # 6440 <malloc+0x92a>
     d68:	00005097          	auipc	ra,0x5
     d6c:	998080e7          	jalr	-1640(ra) # 5700 <write>
     d70:	4795                	li	a5,5
     d72:	10f51863          	bne	a0,a5,e82 <linktest+0x16c>
  close(fd);
     d76:	8526                	mv	a0,s1
     d78:	00005097          	auipc	ra,0x5
     d7c:	990080e7          	jalr	-1648(ra) # 5708 <close>
  if(link("lf1", "lf2") < 0){
     d80:	00005597          	auipc	a1,0x5
     d84:	77858593          	addi	a1,a1,1912 # 64f8 <malloc+0x9e2>
     d88:	00005517          	auipc	a0,0x5
     d8c:	76850513          	addi	a0,a0,1896 # 64f0 <malloc+0x9da>
     d90:	00005097          	auipc	ra,0x5
     d94:	9b0080e7          	jalr	-1616(ra) # 5740 <link>
     d98:	10054363          	bltz	a0,e9e <linktest+0x188>
  unlink("lf1");
     d9c:	00005517          	auipc	a0,0x5
     da0:	75450513          	addi	a0,a0,1876 # 64f0 <malloc+0x9da>
     da4:	00005097          	auipc	ra,0x5
     da8:	98c080e7          	jalr	-1652(ra) # 5730 <unlink>
  if(open("lf1", 0) >= 0){
     dac:	4581                	li	a1,0
     dae:	00005517          	auipc	a0,0x5
     db2:	74250513          	addi	a0,a0,1858 # 64f0 <malloc+0x9da>
     db6:	00005097          	auipc	ra,0x5
     dba:	96a080e7          	jalr	-1686(ra) # 5720 <open>
     dbe:	0e055e63          	bgez	a0,eba <linktest+0x1a4>
  fd = open("lf2", 0);
     dc2:	4581                	li	a1,0
     dc4:	00005517          	auipc	a0,0x5
     dc8:	73450513          	addi	a0,a0,1844 # 64f8 <malloc+0x9e2>
     dcc:	00005097          	auipc	ra,0x5
     dd0:	954080e7          	jalr	-1708(ra) # 5720 <open>
     dd4:	84aa                	mv	s1,a0
  if(fd < 0){
     dd6:	10054063          	bltz	a0,ed6 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     dda:	660d                	lui	a2,0x3
     ddc:	0000b597          	auipc	a1,0xb
     de0:	df458593          	addi	a1,a1,-524 # bbd0 <buf>
     de4:	00005097          	auipc	ra,0x5
     de8:	914080e7          	jalr	-1772(ra) # 56f8 <read>
     dec:	4795                	li	a5,5
     dee:	10f51263          	bne	a0,a5,ef2 <linktest+0x1dc>
  close(fd);
     df2:	8526                	mv	a0,s1
     df4:	00005097          	auipc	ra,0x5
     df8:	914080e7          	jalr	-1772(ra) # 5708 <close>
  if(link("lf2", "lf2") >= 0){
     dfc:	00005597          	auipc	a1,0x5
     e00:	6fc58593          	addi	a1,a1,1788 # 64f8 <malloc+0x9e2>
     e04:	852e                	mv	a0,a1
     e06:	00005097          	auipc	ra,0x5
     e0a:	93a080e7          	jalr	-1734(ra) # 5740 <link>
     e0e:	10055063          	bgez	a0,f0e <linktest+0x1f8>
  unlink("lf2");
     e12:	00005517          	auipc	a0,0x5
     e16:	6e650513          	addi	a0,a0,1766 # 64f8 <malloc+0x9e2>
     e1a:	00005097          	auipc	ra,0x5
     e1e:	916080e7          	jalr	-1770(ra) # 5730 <unlink>
  if(link("lf2", "lf1") >= 0){
     e22:	00005597          	auipc	a1,0x5
     e26:	6ce58593          	addi	a1,a1,1742 # 64f0 <malloc+0x9da>
     e2a:	00005517          	auipc	a0,0x5
     e2e:	6ce50513          	addi	a0,a0,1742 # 64f8 <malloc+0x9e2>
     e32:	00005097          	auipc	ra,0x5
     e36:	90e080e7          	jalr	-1778(ra) # 5740 <link>
     e3a:	0e055863          	bgez	a0,f2a <linktest+0x214>
  if(link(".", "lf1") >= 0){
     e3e:	00005597          	auipc	a1,0x5
     e42:	6b258593          	addi	a1,a1,1714 # 64f0 <malloc+0x9da>
     e46:	00005517          	auipc	a0,0x5
     e4a:	7ba50513          	addi	a0,a0,1978 # 6600 <malloc+0xaea>
     e4e:	00005097          	auipc	ra,0x5
     e52:	8f2080e7          	jalr	-1806(ra) # 5740 <link>
     e56:	0e055863          	bgez	a0,f46 <linktest+0x230>
}
     e5a:	60e2                	ld	ra,24(sp)
     e5c:	6442                	ld	s0,16(sp)
     e5e:	64a2                	ld	s1,8(sp)
     e60:	6902                	ld	s2,0(sp)
     e62:	6105                	addi	sp,sp,32
     e64:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     e66:	85ca                	mv	a1,s2
     e68:	00005517          	auipc	a0,0x5
     e6c:	69850513          	addi	a0,a0,1688 # 6500 <malloc+0x9ea>
     e70:	00005097          	auipc	ra,0x5
     e74:	be8080e7          	jalr	-1048(ra) # 5a58 <printf>
    exit(1);
     e78:	4505                	li	a0,1
     e7a:	00005097          	auipc	ra,0x5
     e7e:	866080e7          	jalr	-1946(ra) # 56e0 <exit>
    printf("%s: write lf1 failed\n", s);
     e82:	85ca                	mv	a1,s2
     e84:	00005517          	auipc	a0,0x5
     e88:	69450513          	addi	a0,a0,1684 # 6518 <malloc+0xa02>
     e8c:	00005097          	auipc	ra,0x5
     e90:	bcc080e7          	jalr	-1076(ra) # 5a58 <printf>
    exit(1);
     e94:	4505                	li	a0,1
     e96:	00005097          	auipc	ra,0x5
     e9a:	84a080e7          	jalr	-1974(ra) # 56e0 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     e9e:	85ca                	mv	a1,s2
     ea0:	00005517          	auipc	a0,0x5
     ea4:	69050513          	addi	a0,a0,1680 # 6530 <malloc+0xa1a>
     ea8:	00005097          	auipc	ra,0x5
     eac:	bb0080e7          	jalr	-1104(ra) # 5a58 <printf>
    exit(1);
     eb0:	4505                	li	a0,1
     eb2:	00005097          	auipc	ra,0x5
     eb6:	82e080e7          	jalr	-2002(ra) # 56e0 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     eba:	85ca                	mv	a1,s2
     ebc:	00005517          	auipc	a0,0x5
     ec0:	69450513          	addi	a0,a0,1684 # 6550 <malloc+0xa3a>
     ec4:	00005097          	auipc	ra,0x5
     ec8:	b94080e7          	jalr	-1132(ra) # 5a58 <printf>
    exit(1);
     ecc:	4505                	li	a0,1
     ece:	00005097          	auipc	ra,0x5
     ed2:	812080e7          	jalr	-2030(ra) # 56e0 <exit>
    printf("%s: open lf2 failed\n", s);
     ed6:	85ca                	mv	a1,s2
     ed8:	00005517          	auipc	a0,0x5
     edc:	6a850513          	addi	a0,a0,1704 # 6580 <malloc+0xa6a>
     ee0:	00005097          	auipc	ra,0x5
     ee4:	b78080e7          	jalr	-1160(ra) # 5a58 <printf>
    exit(1);
     ee8:	4505                	li	a0,1
     eea:	00004097          	auipc	ra,0x4
     eee:	7f6080e7          	jalr	2038(ra) # 56e0 <exit>
    printf("%s: read lf2 failed\n", s);
     ef2:	85ca                	mv	a1,s2
     ef4:	00005517          	auipc	a0,0x5
     ef8:	6a450513          	addi	a0,a0,1700 # 6598 <malloc+0xa82>
     efc:	00005097          	auipc	ra,0x5
     f00:	b5c080e7          	jalr	-1188(ra) # 5a58 <printf>
    exit(1);
     f04:	4505                	li	a0,1
     f06:	00004097          	auipc	ra,0x4
     f0a:	7da080e7          	jalr	2010(ra) # 56e0 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     f0e:	85ca                	mv	a1,s2
     f10:	00005517          	auipc	a0,0x5
     f14:	6a050513          	addi	a0,a0,1696 # 65b0 <malloc+0xa9a>
     f18:	00005097          	auipc	ra,0x5
     f1c:	b40080e7          	jalr	-1216(ra) # 5a58 <printf>
    exit(1);
     f20:	4505                	li	a0,1
     f22:	00004097          	auipc	ra,0x4
     f26:	7be080e7          	jalr	1982(ra) # 56e0 <exit>
    printf("%s: link non-existant succeeded! oops\n", s);
     f2a:	85ca                	mv	a1,s2
     f2c:	00005517          	auipc	a0,0x5
     f30:	6ac50513          	addi	a0,a0,1708 # 65d8 <malloc+0xac2>
     f34:	00005097          	auipc	ra,0x5
     f38:	b24080e7          	jalr	-1244(ra) # 5a58 <printf>
    exit(1);
     f3c:	4505                	li	a0,1
     f3e:	00004097          	auipc	ra,0x4
     f42:	7a2080e7          	jalr	1954(ra) # 56e0 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     f46:	85ca                	mv	a1,s2
     f48:	00005517          	auipc	a0,0x5
     f4c:	6c050513          	addi	a0,a0,1728 # 6608 <malloc+0xaf2>
     f50:	00005097          	auipc	ra,0x5
     f54:	b08080e7          	jalr	-1272(ra) # 5a58 <printf>
    exit(1);
     f58:	4505                	li	a0,1
     f5a:	00004097          	auipc	ra,0x4
     f5e:	786080e7          	jalr	1926(ra) # 56e0 <exit>

0000000000000f62 <bigdir>:
{
     f62:	715d                	addi	sp,sp,-80
     f64:	e486                	sd	ra,72(sp)
     f66:	e0a2                	sd	s0,64(sp)
     f68:	fc26                	sd	s1,56(sp)
     f6a:	f84a                	sd	s2,48(sp)
     f6c:	f44e                	sd	s3,40(sp)
     f6e:	f052                	sd	s4,32(sp)
     f70:	ec56                	sd	s5,24(sp)
     f72:	e85a                	sd	s6,16(sp)
     f74:	0880                	addi	s0,sp,80
     f76:	89aa                	mv	s3,a0
  unlink("bd");
     f78:	00005517          	auipc	a0,0x5
     f7c:	6b050513          	addi	a0,a0,1712 # 6628 <malloc+0xb12>
     f80:	00004097          	auipc	ra,0x4
     f84:	7b0080e7          	jalr	1968(ra) # 5730 <unlink>
  fd = open("bd", O_CREATE);
     f88:	20000593          	li	a1,512
     f8c:	00005517          	auipc	a0,0x5
     f90:	69c50513          	addi	a0,a0,1692 # 6628 <malloc+0xb12>
     f94:	00004097          	auipc	ra,0x4
     f98:	78c080e7          	jalr	1932(ra) # 5720 <open>
  if(fd < 0){
     f9c:	0c054963          	bltz	a0,106e <bigdir+0x10c>
  close(fd);
     fa0:	00004097          	auipc	ra,0x4
     fa4:	768080e7          	jalr	1896(ra) # 5708 <close>
  for(i = 0; i < N; i++){
     fa8:	4901                	li	s2,0
    name[0] = 'x';
     faa:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
     fae:	00005a17          	auipc	s4,0x5
     fb2:	67aa0a13          	addi	s4,s4,1658 # 6628 <malloc+0xb12>
  for(i = 0; i < N; i++){
     fb6:	1f400b13          	li	s6,500
    name[0] = 'x';
     fba:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     fbe:	41f9579b          	sraiw	a5,s2,0x1f
     fc2:	01a7d71b          	srliw	a4,a5,0x1a
     fc6:	012707bb          	addw	a5,a4,s2
     fca:	4067d69b          	sraiw	a3,a5,0x6
     fce:	0306869b          	addiw	a3,a3,48
     fd2:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     fd6:	03f7f793          	andi	a5,a5,63
     fda:	9f99                	subw	a5,a5,a4
     fdc:	0307879b          	addiw	a5,a5,48
     fe0:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     fe4:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
     fe8:	fb040593          	addi	a1,s0,-80
     fec:	8552                	mv	a0,s4
     fee:	00004097          	auipc	ra,0x4
     ff2:	752080e7          	jalr	1874(ra) # 5740 <link>
     ff6:	84aa                	mv	s1,a0
     ff8:	e949                	bnez	a0,108a <bigdir+0x128>
  for(i = 0; i < N; i++){
     ffa:	2905                	addiw	s2,s2,1
     ffc:	fb691fe3          	bne	s2,s6,fba <bigdir+0x58>
  unlink("bd");
    1000:	00005517          	auipc	a0,0x5
    1004:	62850513          	addi	a0,a0,1576 # 6628 <malloc+0xb12>
    1008:	00004097          	auipc	ra,0x4
    100c:	728080e7          	jalr	1832(ra) # 5730 <unlink>
    name[0] = 'x';
    1010:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    1014:	1f400a13          	li	s4,500
    name[0] = 'x';
    1018:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    101c:	41f4d79b          	sraiw	a5,s1,0x1f
    1020:	01a7d71b          	srliw	a4,a5,0x1a
    1024:	009707bb          	addw	a5,a4,s1
    1028:	4067d69b          	sraiw	a3,a5,0x6
    102c:	0306869b          	addiw	a3,a3,48
    1030:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1034:	03f7f793          	andi	a5,a5,63
    1038:	9f99                	subw	a5,a5,a4
    103a:	0307879b          	addiw	a5,a5,48
    103e:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1042:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    1046:	fb040513          	addi	a0,s0,-80
    104a:	00004097          	auipc	ra,0x4
    104e:	6e6080e7          	jalr	1766(ra) # 5730 <unlink>
    1052:	ed21                	bnez	a0,10aa <bigdir+0x148>
  for(i = 0; i < N; i++){
    1054:	2485                	addiw	s1,s1,1
    1056:	fd4491e3          	bne	s1,s4,1018 <bigdir+0xb6>
}
    105a:	60a6                	ld	ra,72(sp)
    105c:	6406                	ld	s0,64(sp)
    105e:	74e2                	ld	s1,56(sp)
    1060:	7942                	ld	s2,48(sp)
    1062:	79a2                	ld	s3,40(sp)
    1064:	7a02                	ld	s4,32(sp)
    1066:	6ae2                	ld	s5,24(sp)
    1068:	6b42                	ld	s6,16(sp)
    106a:	6161                	addi	sp,sp,80
    106c:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    106e:	85ce                	mv	a1,s3
    1070:	00005517          	auipc	a0,0x5
    1074:	5c050513          	addi	a0,a0,1472 # 6630 <malloc+0xb1a>
    1078:	00005097          	auipc	ra,0x5
    107c:	9e0080e7          	jalr	-1568(ra) # 5a58 <printf>
    exit(1);
    1080:	4505                	li	a0,1
    1082:	00004097          	auipc	ra,0x4
    1086:	65e080e7          	jalr	1630(ra) # 56e0 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    108a:	fb040613          	addi	a2,s0,-80
    108e:	85ce                	mv	a1,s3
    1090:	00005517          	auipc	a0,0x5
    1094:	5c050513          	addi	a0,a0,1472 # 6650 <malloc+0xb3a>
    1098:	00005097          	auipc	ra,0x5
    109c:	9c0080e7          	jalr	-1600(ra) # 5a58 <printf>
      exit(1);
    10a0:	4505                	li	a0,1
    10a2:	00004097          	auipc	ra,0x4
    10a6:	63e080e7          	jalr	1598(ra) # 56e0 <exit>
      printf("%s: bigdir unlink failed", s);
    10aa:	85ce                	mv	a1,s3
    10ac:	00005517          	auipc	a0,0x5
    10b0:	5c450513          	addi	a0,a0,1476 # 6670 <malloc+0xb5a>
    10b4:	00005097          	auipc	ra,0x5
    10b8:	9a4080e7          	jalr	-1628(ra) # 5a58 <printf>
      exit(1);
    10bc:	4505                	li	a0,1
    10be:	00004097          	auipc	ra,0x4
    10c2:	622080e7          	jalr	1570(ra) # 56e0 <exit>

00000000000010c6 <validatetest>:
{
    10c6:	7139                	addi	sp,sp,-64
    10c8:	fc06                	sd	ra,56(sp)
    10ca:	f822                	sd	s0,48(sp)
    10cc:	f426                	sd	s1,40(sp)
    10ce:	f04a                	sd	s2,32(sp)
    10d0:	ec4e                	sd	s3,24(sp)
    10d2:	e852                	sd	s4,16(sp)
    10d4:	e456                	sd	s5,8(sp)
    10d6:	e05a                	sd	s6,0(sp)
    10d8:	0080                	addi	s0,sp,64
    10da:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10dc:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    10de:	00005997          	auipc	s3,0x5
    10e2:	5b298993          	addi	s3,s3,1458 # 6690 <malloc+0xb7a>
    10e6:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10e8:	6a85                	lui	s5,0x1
    10ea:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    10ee:	85a6                	mv	a1,s1
    10f0:	854e                	mv	a0,s3
    10f2:	00004097          	auipc	ra,0x4
    10f6:	64e080e7          	jalr	1614(ra) # 5740 <link>
    10fa:	01251f63          	bne	a0,s2,1118 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10fe:	94d6                	add	s1,s1,s5
    1100:	ff4497e3          	bne	s1,s4,10ee <validatetest+0x28>
}
    1104:	70e2                	ld	ra,56(sp)
    1106:	7442                	ld	s0,48(sp)
    1108:	74a2                	ld	s1,40(sp)
    110a:	7902                	ld	s2,32(sp)
    110c:	69e2                	ld	s3,24(sp)
    110e:	6a42                	ld	s4,16(sp)
    1110:	6aa2                	ld	s5,8(sp)
    1112:	6b02                	ld	s6,0(sp)
    1114:	6121                	addi	sp,sp,64
    1116:	8082                	ret
      printf("%s: link should not succeed\n", s);
    1118:	85da                	mv	a1,s6
    111a:	00005517          	auipc	a0,0x5
    111e:	58650513          	addi	a0,a0,1414 # 66a0 <malloc+0xb8a>
    1122:	00005097          	auipc	ra,0x5
    1126:	936080e7          	jalr	-1738(ra) # 5a58 <printf>
      exit(1);
    112a:	4505                	li	a0,1
    112c:	00004097          	auipc	ra,0x4
    1130:	5b4080e7          	jalr	1460(ra) # 56e0 <exit>

0000000000001134 <pgbug>:
// regression test. copyin(), copyout(), and copyinstr() used to cast
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void
pgbug(char *s)
{
    1134:	7179                	addi	sp,sp,-48
    1136:	f406                	sd	ra,40(sp)
    1138:	f022                	sd	s0,32(sp)
    113a:	ec26                	sd	s1,24(sp)
    113c:	1800                	addi	s0,sp,48
  char *argv[1];
  argv[0] = 0;
    113e:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    1142:	00007497          	auipc	s1,0x7
    1146:	25e4b483          	ld	s1,606(s1) # 83a0 <__SDATA_BEGIN__>
    114a:	fd840593          	addi	a1,s0,-40
    114e:	8526                	mv	a0,s1
    1150:	00004097          	auipc	ra,0x4
    1154:	5c8080e7          	jalr	1480(ra) # 5718 <exec>

  pipe((int*)0xeaeb0b5b00002f5e);
    1158:	8526                	mv	a0,s1
    115a:	00004097          	auipc	ra,0x4
    115e:	596080e7          	jalr	1430(ra) # 56f0 <pipe>

  exit(0);
    1162:	4501                	li	a0,0
    1164:	00004097          	auipc	ra,0x4
    1168:	57c080e7          	jalr	1404(ra) # 56e0 <exit>

000000000000116c <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    116c:	7139                	addi	sp,sp,-64
    116e:	fc06                	sd	ra,56(sp)
    1170:	f822                	sd	s0,48(sp)
    1172:	f426                	sd	s1,40(sp)
    1174:	f04a                	sd	s2,32(sp)
    1176:	ec4e                	sd	s3,24(sp)
    1178:	0080                	addi	s0,sp,64
    117a:	64b1                	lui	s1,0xc
    117c:	35048493          	addi	s1,s1,848 # c350 <buf+0x780>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    1180:	597d                	li	s2,-1
    1182:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    1186:	00005997          	auipc	s3,0x5
    118a:	de298993          	addi	s3,s3,-542 # 5f68 <malloc+0x452>
    argv[0] = (char*)0xffffffff;
    118e:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1192:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    1196:	fc040593          	addi	a1,s0,-64
    119a:	854e                	mv	a0,s3
    119c:	00004097          	auipc	ra,0x4
    11a0:	57c080e7          	jalr	1404(ra) # 5718 <exec>
  for(int i = 0; i < 50000; i++){
    11a4:	34fd                	addiw	s1,s1,-1
    11a6:	f4e5                	bnez	s1,118e <badarg+0x22>
  }

  exit(0);
    11a8:	4501                	li	a0,0
    11aa:	00004097          	auipc	ra,0x4
    11ae:	536080e7          	jalr	1334(ra) # 56e0 <exit>

00000000000011b2 <copyinstr2>:
{
    11b2:	7155                	addi	sp,sp,-208
    11b4:	e586                	sd	ra,200(sp)
    11b6:	e1a2                	sd	s0,192(sp)
    11b8:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    11ba:	f6840793          	addi	a5,s0,-152
    11be:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    11c2:	07800713          	li	a4,120
    11c6:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    11ca:	0785                	addi	a5,a5,1
    11cc:	fed79de3          	bne	a5,a3,11c6 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    11d0:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    11d4:	f6840513          	addi	a0,s0,-152
    11d8:	00004097          	auipc	ra,0x4
    11dc:	558080e7          	jalr	1368(ra) # 5730 <unlink>
  if(ret != -1){
    11e0:	57fd                	li	a5,-1
    11e2:	0ef51063          	bne	a0,a5,12c2 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    11e6:	20100593          	li	a1,513
    11ea:	f6840513          	addi	a0,s0,-152
    11ee:	00004097          	auipc	ra,0x4
    11f2:	532080e7          	jalr	1330(ra) # 5720 <open>
  if(fd != -1){
    11f6:	57fd                	li	a5,-1
    11f8:	0ef51563          	bne	a0,a5,12e2 <copyinstr2+0x130>
  ret = link(b, b);
    11fc:	f6840593          	addi	a1,s0,-152
    1200:	852e                	mv	a0,a1
    1202:	00004097          	auipc	ra,0x4
    1206:	53e080e7          	jalr	1342(ra) # 5740 <link>
  if(ret != -1){
    120a:	57fd                	li	a5,-1
    120c:	0ef51b63          	bne	a0,a5,1302 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    1210:	00006797          	auipc	a5,0x6
    1214:	66078793          	addi	a5,a5,1632 # 7870 <malloc+0x1d5a>
    1218:	f4f43c23          	sd	a5,-168(s0)
    121c:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1220:	f5840593          	addi	a1,s0,-168
    1224:	f6840513          	addi	a0,s0,-152
    1228:	00004097          	auipc	ra,0x4
    122c:	4f0080e7          	jalr	1264(ra) # 5718 <exec>
  if(ret != -1){
    1230:	57fd                	li	a5,-1
    1232:	0ef51963          	bne	a0,a5,1324 <copyinstr2+0x172>
  int pid = fork();
    1236:	00004097          	auipc	ra,0x4
    123a:	4a2080e7          	jalr	1186(ra) # 56d8 <fork>
  if(pid < 0){
    123e:	10054363          	bltz	a0,1344 <copyinstr2+0x192>
  if(pid == 0){
    1242:	12051463          	bnez	a0,136a <copyinstr2+0x1b8>
    1246:	00007797          	auipc	a5,0x7
    124a:	27278793          	addi	a5,a5,626 # 84b8 <big.0>
    124e:	00008697          	auipc	a3,0x8
    1252:	26a68693          	addi	a3,a3,618 # 94b8 <__global_pointer$+0x918>
      big[i] = 'x';
    1256:	07800713          	li	a4,120
    125a:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    125e:	0785                	addi	a5,a5,1
    1260:	fed79de3          	bne	a5,a3,125a <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1264:	00008797          	auipc	a5,0x8
    1268:	24078a23          	sb	zero,596(a5) # 94b8 <__global_pointer$+0x918>
    char *args2[] = { big, big, big, 0 };
    126c:	00007797          	auipc	a5,0x7
    1270:	d3478793          	addi	a5,a5,-716 # 7fa0 <malloc+0x248a>
    1274:	6390                	ld	a2,0(a5)
    1276:	6794                	ld	a3,8(a5)
    1278:	6b98                	ld	a4,16(a5)
    127a:	6f9c                	ld	a5,24(a5)
    127c:	f2c43823          	sd	a2,-208(s0)
    1280:	f2d43c23          	sd	a3,-200(s0)
    1284:	f4e43023          	sd	a4,-192(s0)
    1288:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    128c:	f3040593          	addi	a1,s0,-208
    1290:	00005517          	auipc	a0,0x5
    1294:	cd850513          	addi	a0,a0,-808 # 5f68 <malloc+0x452>
    1298:	00004097          	auipc	ra,0x4
    129c:	480080e7          	jalr	1152(ra) # 5718 <exec>
    if(ret != -1){
    12a0:	57fd                	li	a5,-1
    12a2:	0af50e63          	beq	a0,a5,135e <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    12a6:	55fd                	li	a1,-1
    12a8:	00005517          	auipc	a0,0x5
    12ac:	4a050513          	addi	a0,a0,1184 # 6748 <malloc+0xc32>
    12b0:	00004097          	auipc	ra,0x4
    12b4:	7a8080e7          	jalr	1960(ra) # 5a58 <printf>
      exit(1);
    12b8:	4505                	li	a0,1
    12ba:	00004097          	auipc	ra,0x4
    12be:	426080e7          	jalr	1062(ra) # 56e0 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    12c2:	862a                	mv	a2,a0
    12c4:	f6840593          	addi	a1,s0,-152
    12c8:	00005517          	auipc	a0,0x5
    12cc:	3f850513          	addi	a0,a0,1016 # 66c0 <malloc+0xbaa>
    12d0:	00004097          	auipc	ra,0x4
    12d4:	788080e7          	jalr	1928(ra) # 5a58 <printf>
    exit(1);
    12d8:	4505                	li	a0,1
    12da:	00004097          	auipc	ra,0x4
    12de:	406080e7          	jalr	1030(ra) # 56e0 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    12e2:	862a                	mv	a2,a0
    12e4:	f6840593          	addi	a1,s0,-152
    12e8:	00005517          	auipc	a0,0x5
    12ec:	3f850513          	addi	a0,a0,1016 # 66e0 <malloc+0xbca>
    12f0:	00004097          	auipc	ra,0x4
    12f4:	768080e7          	jalr	1896(ra) # 5a58 <printf>
    exit(1);
    12f8:	4505                	li	a0,1
    12fa:	00004097          	auipc	ra,0x4
    12fe:	3e6080e7          	jalr	998(ra) # 56e0 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1302:	86aa                	mv	a3,a0
    1304:	f6840613          	addi	a2,s0,-152
    1308:	85b2                	mv	a1,a2
    130a:	00005517          	auipc	a0,0x5
    130e:	3f650513          	addi	a0,a0,1014 # 6700 <malloc+0xbea>
    1312:	00004097          	auipc	ra,0x4
    1316:	746080e7          	jalr	1862(ra) # 5a58 <printf>
    exit(1);
    131a:	4505                	li	a0,1
    131c:	00004097          	auipc	ra,0x4
    1320:	3c4080e7          	jalr	964(ra) # 56e0 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1324:	567d                	li	a2,-1
    1326:	f6840593          	addi	a1,s0,-152
    132a:	00005517          	auipc	a0,0x5
    132e:	3fe50513          	addi	a0,a0,1022 # 6728 <malloc+0xc12>
    1332:	00004097          	auipc	ra,0x4
    1336:	726080e7          	jalr	1830(ra) # 5a58 <printf>
    exit(1);
    133a:	4505                	li	a0,1
    133c:	00004097          	auipc	ra,0x4
    1340:	3a4080e7          	jalr	932(ra) # 56e0 <exit>
    printf("fork failed\n");
    1344:	00006517          	auipc	a0,0x6
    1348:	86450513          	addi	a0,a0,-1948 # 6ba8 <malloc+0x1092>
    134c:	00004097          	auipc	ra,0x4
    1350:	70c080e7          	jalr	1804(ra) # 5a58 <printf>
    exit(1);
    1354:	4505                	li	a0,1
    1356:	00004097          	auipc	ra,0x4
    135a:	38a080e7          	jalr	906(ra) # 56e0 <exit>
    exit(747); // OK
    135e:	2eb00513          	li	a0,747
    1362:	00004097          	auipc	ra,0x4
    1366:	37e080e7          	jalr	894(ra) # 56e0 <exit>
  int st = 0;
    136a:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    136e:	f5440513          	addi	a0,s0,-172
    1372:	00004097          	auipc	ra,0x4
    1376:	376080e7          	jalr	886(ra) # 56e8 <wait>
  if(st != 747){
    137a:	f5442703          	lw	a4,-172(s0)
    137e:	2eb00793          	li	a5,747
    1382:	00f71663          	bne	a4,a5,138e <copyinstr2+0x1dc>
}
    1386:	60ae                	ld	ra,200(sp)
    1388:	640e                	ld	s0,192(sp)
    138a:	6169                	addi	sp,sp,208
    138c:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    138e:	00005517          	auipc	a0,0x5
    1392:	3e250513          	addi	a0,a0,994 # 6770 <malloc+0xc5a>
    1396:	00004097          	auipc	ra,0x4
    139a:	6c2080e7          	jalr	1730(ra) # 5a58 <printf>
    exit(1);
    139e:	4505                	li	a0,1
    13a0:	00004097          	auipc	ra,0x4
    13a4:	340080e7          	jalr	832(ra) # 56e0 <exit>

00000000000013a8 <truncate3>:
{
    13a8:	7159                	addi	sp,sp,-112
    13aa:	f486                	sd	ra,104(sp)
    13ac:	f0a2                	sd	s0,96(sp)
    13ae:	eca6                	sd	s1,88(sp)
    13b0:	e8ca                	sd	s2,80(sp)
    13b2:	e4ce                	sd	s3,72(sp)
    13b4:	e0d2                	sd	s4,64(sp)
    13b6:	fc56                	sd	s5,56(sp)
    13b8:	1880                	addi	s0,sp,112
    13ba:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    13bc:	60100593          	li	a1,1537
    13c0:	00005517          	auipc	a0,0x5
    13c4:	c0050513          	addi	a0,a0,-1024 # 5fc0 <malloc+0x4aa>
    13c8:	00004097          	auipc	ra,0x4
    13cc:	358080e7          	jalr	856(ra) # 5720 <open>
    13d0:	00004097          	auipc	ra,0x4
    13d4:	338080e7          	jalr	824(ra) # 5708 <close>
  pid = fork();
    13d8:	00004097          	auipc	ra,0x4
    13dc:	300080e7          	jalr	768(ra) # 56d8 <fork>
  if(pid < 0){
    13e0:	08054063          	bltz	a0,1460 <truncate3+0xb8>
  if(pid == 0){
    13e4:	e969                	bnez	a0,14b6 <truncate3+0x10e>
    13e6:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    13ea:	00005a17          	auipc	s4,0x5
    13ee:	bd6a0a13          	addi	s4,s4,-1066 # 5fc0 <malloc+0x4aa>
      int n = write(fd, "1234567890", 10);
    13f2:	00005a97          	auipc	s5,0x5
    13f6:	3dea8a93          	addi	s5,s5,990 # 67d0 <malloc+0xcba>
      int fd = open("truncfile", O_WRONLY);
    13fa:	4585                	li	a1,1
    13fc:	8552                	mv	a0,s4
    13fe:	00004097          	auipc	ra,0x4
    1402:	322080e7          	jalr	802(ra) # 5720 <open>
    1406:	84aa                	mv	s1,a0
      if(fd < 0){
    1408:	06054a63          	bltz	a0,147c <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    140c:	4629                	li	a2,10
    140e:	85d6                	mv	a1,s5
    1410:	00004097          	auipc	ra,0x4
    1414:	2f0080e7          	jalr	752(ra) # 5700 <write>
      if(n != 10){
    1418:	47a9                	li	a5,10
    141a:	06f51f63          	bne	a0,a5,1498 <truncate3+0xf0>
      close(fd);
    141e:	8526                	mv	a0,s1
    1420:	00004097          	auipc	ra,0x4
    1424:	2e8080e7          	jalr	744(ra) # 5708 <close>
      fd = open("truncfile", O_RDONLY);
    1428:	4581                	li	a1,0
    142a:	8552                	mv	a0,s4
    142c:	00004097          	auipc	ra,0x4
    1430:	2f4080e7          	jalr	756(ra) # 5720 <open>
    1434:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    1436:	02000613          	li	a2,32
    143a:	f9840593          	addi	a1,s0,-104
    143e:	00004097          	auipc	ra,0x4
    1442:	2ba080e7          	jalr	698(ra) # 56f8 <read>
      close(fd);
    1446:	8526                	mv	a0,s1
    1448:	00004097          	auipc	ra,0x4
    144c:	2c0080e7          	jalr	704(ra) # 5708 <close>
    for(int i = 0; i < 100; i++){
    1450:	39fd                	addiw	s3,s3,-1
    1452:	fa0994e3          	bnez	s3,13fa <truncate3+0x52>
    exit(0);
    1456:	4501                	li	a0,0
    1458:	00004097          	auipc	ra,0x4
    145c:	288080e7          	jalr	648(ra) # 56e0 <exit>
    printf("%s: fork failed\n", s);
    1460:	85ca                	mv	a1,s2
    1462:	00005517          	auipc	a0,0x5
    1466:	33e50513          	addi	a0,a0,830 # 67a0 <malloc+0xc8a>
    146a:	00004097          	auipc	ra,0x4
    146e:	5ee080e7          	jalr	1518(ra) # 5a58 <printf>
    exit(1);
    1472:	4505                	li	a0,1
    1474:	00004097          	auipc	ra,0x4
    1478:	26c080e7          	jalr	620(ra) # 56e0 <exit>
        printf("%s: open failed\n", s);
    147c:	85ca                	mv	a1,s2
    147e:	00005517          	auipc	a0,0x5
    1482:	33a50513          	addi	a0,a0,826 # 67b8 <malloc+0xca2>
    1486:	00004097          	auipc	ra,0x4
    148a:	5d2080e7          	jalr	1490(ra) # 5a58 <printf>
        exit(1);
    148e:	4505                	li	a0,1
    1490:	00004097          	auipc	ra,0x4
    1494:	250080e7          	jalr	592(ra) # 56e0 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    1498:	862a                	mv	a2,a0
    149a:	85ca                	mv	a1,s2
    149c:	00005517          	auipc	a0,0x5
    14a0:	34450513          	addi	a0,a0,836 # 67e0 <malloc+0xcca>
    14a4:	00004097          	auipc	ra,0x4
    14a8:	5b4080e7          	jalr	1460(ra) # 5a58 <printf>
        exit(1);
    14ac:	4505                	li	a0,1
    14ae:	00004097          	auipc	ra,0x4
    14b2:	232080e7          	jalr	562(ra) # 56e0 <exit>
    14b6:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14ba:	00005a17          	auipc	s4,0x5
    14be:	b06a0a13          	addi	s4,s4,-1274 # 5fc0 <malloc+0x4aa>
    int n = write(fd, "xxx", 3);
    14c2:	00005a97          	auipc	s5,0x5
    14c6:	33ea8a93          	addi	s5,s5,830 # 6800 <malloc+0xcea>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14ca:	60100593          	li	a1,1537
    14ce:	8552                	mv	a0,s4
    14d0:	00004097          	auipc	ra,0x4
    14d4:	250080e7          	jalr	592(ra) # 5720 <open>
    14d8:	84aa                	mv	s1,a0
    if(fd < 0){
    14da:	04054763          	bltz	a0,1528 <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    14de:	460d                	li	a2,3
    14e0:	85d6                	mv	a1,s5
    14e2:	00004097          	auipc	ra,0x4
    14e6:	21e080e7          	jalr	542(ra) # 5700 <write>
    if(n != 3){
    14ea:	478d                	li	a5,3
    14ec:	04f51c63          	bne	a0,a5,1544 <truncate3+0x19c>
    close(fd);
    14f0:	8526                	mv	a0,s1
    14f2:	00004097          	auipc	ra,0x4
    14f6:	216080e7          	jalr	534(ra) # 5708 <close>
  for(int i = 0; i < 150; i++){
    14fa:	39fd                	addiw	s3,s3,-1
    14fc:	fc0997e3          	bnez	s3,14ca <truncate3+0x122>
  wait(&xstatus);
    1500:	fbc40513          	addi	a0,s0,-68
    1504:	00004097          	auipc	ra,0x4
    1508:	1e4080e7          	jalr	484(ra) # 56e8 <wait>
  unlink("truncfile");
    150c:	00005517          	auipc	a0,0x5
    1510:	ab450513          	addi	a0,a0,-1356 # 5fc0 <malloc+0x4aa>
    1514:	00004097          	auipc	ra,0x4
    1518:	21c080e7          	jalr	540(ra) # 5730 <unlink>
  exit(xstatus);
    151c:	fbc42503          	lw	a0,-68(s0)
    1520:	00004097          	auipc	ra,0x4
    1524:	1c0080e7          	jalr	448(ra) # 56e0 <exit>
      printf("%s: open failed\n", s);
    1528:	85ca                	mv	a1,s2
    152a:	00005517          	auipc	a0,0x5
    152e:	28e50513          	addi	a0,a0,654 # 67b8 <malloc+0xca2>
    1532:	00004097          	auipc	ra,0x4
    1536:	526080e7          	jalr	1318(ra) # 5a58 <printf>
      exit(1);
    153a:	4505                	li	a0,1
    153c:	00004097          	auipc	ra,0x4
    1540:	1a4080e7          	jalr	420(ra) # 56e0 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1544:	862a                	mv	a2,a0
    1546:	85ca                	mv	a1,s2
    1548:	00005517          	auipc	a0,0x5
    154c:	2c050513          	addi	a0,a0,704 # 6808 <malloc+0xcf2>
    1550:	00004097          	auipc	ra,0x4
    1554:	508080e7          	jalr	1288(ra) # 5a58 <printf>
      exit(1);
    1558:	4505                	li	a0,1
    155a:	00004097          	auipc	ra,0x4
    155e:	186080e7          	jalr	390(ra) # 56e0 <exit>

0000000000001562 <exectest>:
{
    1562:	715d                	addi	sp,sp,-80
    1564:	e486                	sd	ra,72(sp)
    1566:	e0a2                	sd	s0,64(sp)
    1568:	fc26                	sd	s1,56(sp)
    156a:	f84a                	sd	s2,48(sp)
    156c:	0880                	addi	s0,sp,80
    156e:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    1570:	00005797          	auipc	a5,0x5
    1574:	9f878793          	addi	a5,a5,-1544 # 5f68 <malloc+0x452>
    1578:	fcf43023          	sd	a5,-64(s0)
    157c:	00005797          	auipc	a5,0x5
    1580:	2ac78793          	addi	a5,a5,684 # 6828 <malloc+0xd12>
    1584:	fcf43423          	sd	a5,-56(s0)
    1588:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    158c:	00005517          	auipc	a0,0x5
    1590:	2a450513          	addi	a0,a0,676 # 6830 <malloc+0xd1a>
    1594:	00004097          	auipc	ra,0x4
    1598:	19c080e7          	jalr	412(ra) # 5730 <unlink>
  pid = fork();
    159c:	00004097          	auipc	ra,0x4
    15a0:	13c080e7          	jalr	316(ra) # 56d8 <fork>
  if(pid < 0) {
    15a4:	04054663          	bltz	a0,15f0 <exectest+0x8e>
    15a8:	84aa                	mv	s1,a0
  if(pid == 0) {
    15aa:	e959                	bnez	a0,1640 <exectest+0xde>
    close(1);
    15ac:	4505                	li	a0,1
    15ae:	00004097          	auipc	ra,0x4
    15b2:	15a080e7          	jalr	346(ra) # 5708 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    15b6:	20100593          	li	a1,513
    15ba:	00005517          	auipc	a0,0x5
    15be:	27650513          	addi	a0,a0,630 # 6830 <malloc+0xd1a>
    15c2:	00004097          	auipc	ra,0x4
    15c6:	15e080e7          	jalr	350(ra) # 5720 <open>
    if(fd < 0) {
    15ca:	04054163          	bltz	a0,160c <exectest+0xaa>
    if(fd != 1) {
    15ce:	4785                	li	a5,1
    15d0:	04f50c63          	beq	a0,a5,1628 <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    15d4:	85ca                	mv	a1,s2
    15d6:	00005517          	auipc	a0,0x5
    15da:	27a50513          	addi	a0,a0,634 # 6850 <malloc+0xd3a>
    15de:	00004097          	auipc	ra,0x4
    15e2:	47a080e7          	jalr	1146(ra) # 5a58 <printf>
      exit(1);
    15e6:	4505                	li	a0,1
    15e8:	00004097          	auipc	ra,0x4
    15ec:	0f8080e7          	jalr	248(ra) # 56e0 <exit>
     printf("%s: fork failed\n", s);
    15f0:	85ca                	mv	a1,s2
    15f2:	00005517          	auipc	a0,0x5
    15f6:	1ae50513          	addi	a0,a0,430 # 67a0 <malloc+0xc8a>
    15fa:	00004097          	auipc	ra,0x4
    15fe:	45e080e7          	jalr	1118(ra) # 5a58 <printf>
     exit(1);
    1602:	4505                	li	a0,1
    1604:	00004097          	auipc	ra,0x4
    1608:	0dc080e7          	jalr	220(ra) # 56e0 <exit>
      printf("%s: create failed\n", s);
    160c:	85ca                	mv	a1,s2
    160e:	00005517          	auipc	a0,0x5
    1612:	22a50513          	addi	a0,a0,554 # 6838 <malloc+0xd22>
    1616:	00004097          	auipc	ra,0x4
    161a:	442080e7          	jalr	1090(ra) # 5a58 <printf>
      exit(1);
    161e:	4505                	li	a0,1
    1620:	00004097          	auipc	ra,0x4
    1624:	0c0080e7          	jalr	192(ra) # 56e0 <exit>
    if(exec("echo", echoargv) < 0){
    1628:	fc040593          	addi	a1,s0,-64
    162c:	00005517          	auipc	a0,0x5
    1630:	93c50513          	addi	a0,a0,-1732 # 5f68 <malloc+0x452>
    1634:	00004097          	auipc	ra,0x4
    1638:	0e4080e7          	jalr	228(ra) # 5718 <exec>
    163c:	02054163          	bltz	a0,165e <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    1640:	fdc40513          	addi	a0,s0,-36
    1644:	00004097          	auipc	ra,0x4
    1648:	0a4080e7          	jalr	164(ra) # 56e8 <wait>
    164c:	02951763          	bne	a0,s1,167a <exectest+0x118>
  if(xstatus != 0)
    1650:	fdc42503          	lw	a0,-36(s0)
    1654:	cd0d                	beqz	a0,168e <exectest+0x12c>
    exit(xstatus);
    1656:	00004097          	auipc	ra,0x4
    165a:	08a080e7          	jalr	138(ra) # 56e0 <exit>
      printf("%s: exec echo failed\n", s);
    165e:	85ca                	mv	a1,s2
    1660:	00005517          	auipc	a0,0x5
    1664:	20050513          	addi	a0,a0,512 # 6860 <malloc+0xd4a>
    1668:	00004097          	auipc	ra,0x4
    166c:	3f0080e7          	jalr	1008(ra) # 5a58 <printf>
      exit(1);
    1670:	4505                	li	a0,1
    1672:	00004097          	auipc	ra,0x4
    1676:	06e080e7          	jalr	110(ra) # 56e0 <exit>
    printf("%s: wait failed!\n", s);
    167a:	85ca                	mv	a1,s2
    167c:	00005517          	auipc	a0,0x5
    1680:	1fc50513          	addi	a0,a0,508 # 6878 <malloc+0xd62>
    1684:	00004097          	auipc	ra,0x4
    1688:	3d4080e7          	jalr	980(ra) # 5a58 <printf>
    168c:	b7d1                	j	1650 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    168e:	4581                	li	a1,0
    1690:	00005517          	auipc	a0,0x5
    1694:	1a050513          	addi	a0,a0,416 # 6830 <malloc+0xd1a>
    1698:	00004097          	auipc	ra,0x4
    169c:	088080e7          	jalr	136(ra) # 5720 <open>
  if(fd < 0) {
    16a0:	02054a63          	bltz	a0,16d4 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    16a4:	4609                	li	a2,2
    16a6:	fb840593          	addi	a1,s0,-72
    16aa:	00004097          	auipc	ra,0x4
    16ae:	04e080e7          	jalr	78(ra) # 56f8 <read>
    16b2:	4789                	li	a5,2
    16b4:	02f50e63          	beq	a0,a5,16f0 <exectest+0x18e>
    printf("%s: read failed\n", s);
    16b8:	85ca                	mv	a1,s2
    16ba:	00005517          	auipc	a0,0x5
    16be:	c3e50513          	addi	a0,a0,-962 # 62f8 <malloc+0x7e2>
    16c2:	00004097          	auipc	ra,0x4
    16c6:	396080e7          	jalr	918(ra) # 5a58 <printf>
    exit(1);
    16ca:	4505                	li	a0,1
    16cc:	00004097          	auipc	ra,0x4
    16d0:	014080e7          	jalr	20(ra) # 56e0 <exit>
    printf("%s: open failed\n", s);
    16d4:	85ca                	mv	a1,s2
    16d6:	00005517          	auipc	a0,0x5
    16da:	0e250513          	addi	a0,a0,226 # 67b8 <malloc+0xca2>
    16de:	00004097          	auipc	ra,0x4
    16e2:	37a080e7          	jalr	890(ra) # 5a58 <printf>
    exit(1);
    16e6:	4505                	li	a0,1
    16e8:	00004097          	auipc	ra,0x4
    16ec:	ff8080e7          	jalr	-8(ra) # 56e0 <exit>
  unlink("echo-ok");
    16f0:	00005517          	auipc	a0,0x5
    16f4:	14050513          	addi	a0,a0,320 # 6830 <malloc+0xd1a>
    16f8:	00004097          	auipc	ra,0x4
    16fc:	038080e7          	jalr	56(ra) # 5730 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1700:	fb844703          	lbu	a4,-72(s0)
    1704:	04f00793          	li	a5,79
    1708:	00f71863          	bne	a4,a5,1718 <exectest+0x1b6>
    170c:	fb944703          	lbu	a4,-71(s0)
    1710:	04b00793          	li	a5,75
    1714:	02f70063          	beq	a4,a5,1734 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    1718:	85ca                	mv	a1,s2
    171a:	00005517          	auipc	a0,0x5
    171e:	17650513          	addi	a0,a0,374 # 6890 <malloc+0xd7a>
    1722:	00004097          	auipc	ra,0x4
    1726:	336080e7          	jalr	822(ra) # 5a58 <printf>
    exit(1);
    172a:	4505                	li	a0,1
    172c:	00004097          	auipc	ra,0x4
    1730:	fb4080e7          	jalr	-76(ra) # 56e0 <exit>
    exit(0);
    1734:	4501                	li	a0,0
    1736:	00004097          	auipc	ra,0x4
    173a:	faa080e7          	jalr	-86(ra) # 56e0 <exit>

000000000000173e <pipe1>:
{
    173e:	711d                	addi	sp,sp,-96
    1740:	ec86                	sd	ra,88(sp)
    1742:	e8a2                	sd	s0,80(sp)
    1744:	e4a6                	sd	s1,72(sp)
    1746:	e0ca                	sd	s2,64(sp)
    1748:	fc4e                	sd	s3,56(sp)
    174a:	f852                	sd	s4,48(sp)
    174c:	f456                	sd	s5,40(sp)
    174e:	f05a                	sd	s6,32(sp)
    1750:	ec5e                	sd	s7,24(sp)
    1752:	1080                	addi	s0,sp,96
    1754:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    1756:	fa840513          	addi	a0,s0,-88
    175a:	00004097          	auipc	ra,0x4
    175e:	f96080e7          	jalr	-106(ra) # 56f0 <pipe>
    1762:	ed25                	bnez	a0,17da <pipe1+0x9c>
    1764:	84aa                	mv	s1,a0
  pid = fork();
    1766:	00004097          	auipc	ra,0x4
    176a:	f72080e7          	jalr	-142(ra) # 56d8 <fork>
    176e:	8a2a                	mv	s4,a0
  if(pid == 0){
    1770:	c159                	beqz	a0,17f6 <pipe1+0xb8>
  } else if(pid > 0){
    1772:	16a05e63          	blez	a0,18ee <pipe1+0x1b0>
    close(fds[1]);
    1776:	fac42503          	lw	a0,-84(s0)
    177a:	00004097          	auipc	ra,0x4
    177e:	f8e080e7          	jalr	-114(ra) # 5708 <close>
    total = 0;
    1782:	8a26                	mv	s4,s1
    cc = 1;
    1784:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    1786:	0000aa97          	auipc	s5,0xa
    178a:	44aa8a93          	addi	s5,s5,1098 # bbd0 <buf>
      if(cc > sizeof(buf))
    178e:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    1790:	864e                	mv	a2,s3
    1792:	85d6                	mv	a1,s5
    1794:	fa842503          	lw	a0,-88(s0)
    1798:	00004097          	auipc	ra,0x4
    179c:	f60080e7          	jalr	-160(ra) # 56f8 <read>
    17a0:	10a05263          	blez	a0,18a4 <pipe1+0x166>
      for(i = 0; i < n; i++){
    17a4:	0000a717          	auipc	a4,0xa
    17a8:	42c70713          	addi	a4,a4,1068 # bbd0 <buf>
    17ac:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17b0:	00074683          	lbu	a3,0(a4)
    17b4:	0ff4f793          	andi	a5,s1,255
    17b8:	2485                	addiw	s1,s1,1
    17ba:	0cf69163          	bne	a3,a5,187c <pipe1+0x13e>
      for(i = 0; i < n; i++){
    17be:	0705                	addi	a4,a4,1
    17c0:	fec498e3          	bne	s1,a2,17b0 <pipe1+0x72>
      total += n;
    17c4:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    17c8:	0019979b          	slliw	a5,s3,0x1
    17cc:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    17d0:	013b7363          	bgeu	s6,s3,17d6 <pipe1+0x98>
        cc = sizeof(buf);
    17d4:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17d6:	84b2                	mv	s1,a2
    17d8:	bf65                	j	1790 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    17da:	85ca                	mv	a1,s2
    17dc:	00005517          	auipc	a0,0x5
    17e0:	0cc50513          	addi	a0,a0,204 # 68a8 <malloc+0xd92>
    17e4:	00004097          	auipc	ra,0x4
    17e8:	274080e7          	jalr	628(ra) # 5a58 <printf>
    exit(1);
    17ec:	4505                	li	a0,1
    17ee:	00004097          	auipc	ra,0x4
    17f2:	ef2080e7          	jalr	-270(ra) # 56e0 <exit>
    close(fds[0]);
    17f6:	fa842503          	lw	a0,-88(s0)
    17fa:	00004097          	auipc	ra,0x4
    17fe:	f0e080e7          	jalr	-242(ra) # 5708 <close>
    for(n = 0; n < N; n++){
    1802:	0000ab17          	auipc	s6,0xa
    1806:	3ceb0b13          	addi	s6,s6,974 # bbd0 <buf>
    180a:	416004bb          	negw	s1,s6
    180e:	0ff4f493          	andi	s1,s1,255
    1812:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    1816:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    1818:	6a85                	lui	s5,0x1
    181a:	42da8a93          	addi	s5,s5,1069 # 142d <truncate3+0x85>
{
    181e:	87da                	mv	a5,s6
        buf[i] = seq++;
    1820:	0097873b          	addw	a4,a5,s1
    1824:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1828:	0785                	addi	a5,a5,1
    182a:	fef99be3          	bne	s3,a5,1820 <pipe1+0xe2>
        buf[i] = seq++;
    182e:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1832:	40900613          	li	a2,1033
    1836:	85de                	mv	a1,s7
    1838:	fac42503          	lw	a0,-84(s0)
    183c:	00004097          	auipc	ra,0x4
    1840:	ec4080e7          	jalr	-316(ra) # 5700 <write>
    1844:	40900793          	li	a5,1033
    1848:	00f51c63          	bne	a0,a5,1860 <pipe1+0x122>
    for(n = 0; n < N; n++){
    184c:	24a5                	addiw	s1,s1,9
    184e:	0ff4f493          	andi	s1,s1,255
    1852:	fd5a16e3          	bne	s4,s5,181e <pipe1+0xe0>
    exit(0);
    1856:	4501                	li	a0,0
    1858:	00004097          	auipc	ra,0x4
    185c:	e88080e7          	jalr	-376(ra) # 56e0 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1860:	85ca                	mv	a1,s2
    1862:	00005517          	auipc	a0,0x5
    1866:	05e50513          	addi	a0,a0,94 # 68c0 <malloc+0xdaa>
    186a:	00004097          	auipc	ra,0x4
    186e:	1ee080e7          	jalr	494(ra) # 5a58 <printf>
        exit(1);
    1872:	4505                	li	a0,1
    1874:	00004097          	auipc	ra,0x4
    1878:	e6c080e7          	jalr	-404(ra) # 56e0 <exit>
          printf("%s: pipe1 oops 2\n", s);
    187c:	85ca                	mv	a1,s2
    187e:	00005517          	auipc	a0,0x5
    1882:	05a50513          	addi	a0,a0,90 # 68d8 <malloc+0xdc2>
    1886:	00004097          	auipc	ra,0x4
    188a:	1d2080e7          	jalr	466(ra) # 5a58 <printf>
}
    188e:	60e6                	ld	ra,88(sp)
    1890:	6446                	ld	s0,80(sp)
    1892:	64a6                	ld	s1,72(sp)
    1894:	6906                	ld	s2,64(sp)
    1896:	79e2                	ld	s3,56(sp)
    1898:	7a42                	ld	s4,48(sp)
    189a:	7aa2                	ld	s5,40(sp)
    189c:	7b02                	ld	s6,32(sp)
    189e:	6be2                	ld	s7,24(sp)
    18a0:	6125                	addi	sp,sp,96
    18a2:	8082                	ret
    if(total != N * SZ){
    18a4:	6785                	lui	a5,0x1
    18a6:	42d78793          	addi	a5,a5,1069 # 142d <truncate3+0x85>
    18aa:	02fa0063          	beq	s4,a5,18ca <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    18ae:	85d2                	mv	a1,s4
    18b0:	00005517          	auipc	a0,0x5
    18b4:	04050513          	addi	a0,a0,64 # 68f0 <malloc+0xdda>
    18b8:	00004097          	auipc	ra,0x4
    18bc:	1a0080e7          	jalr	416(ra) # 5a58 <printf>
      exit(1);
    18c0:	4505                	li	a0,1
    18c2:	00004097          	auipc	ra,0x4
    18c6:	e1e080e7          	jalr	-482(ra) # 56e0 <exit>
    close(fds[0]);
    18ca:	fa842503          	lw	a0,-88(s0)
    18ce:	00004097          	auipc	ra,0x4
    18d2:	e3a080e7          	jalr	-454(ra) # 5708 <close>
    wait(&xstatus);
    18d6:	fa440513          	addi	a0,s0,-92
    18da:	00004097          	auipc	ra,0x4
    18de:	e0e080e7          	jalr	-498(ra) # 56e8 <wait>
    exit(xstatus);
    18e2:	fa442503          	lw	a0,-92(s0)
    18e6:	00004097          	auipc	ra,0x4
    18ea:	dfa080e7          	jalr	-518(ra) # 56e0 <exit>
    printf("%s: fork() failed\n", s);
    18ee:	85ca                	mv	a1,s2
    18f0:	00005517          	auipc	a0,0x5
    18f4:	02050513          	addi	a0,a0,32 # 6910 <malloc+0xdfa>
    18f8:	00004097          	auipc	ra,0x4
    18fc:	160080e7          	jalr	352(ra) # 5a58 <printf>
    exit(1);
    1900:	4505                	li	a0,1
    1902:	00004097          	auipc	ra,0x4
    1906:	dde080e7          	jalr	-546(ra) # 56e0 <exit>

000000000000190a <exitwait>:
{
    190a:	7139                	addi	sp,sp,-64
    190c:	fc06                	sd	ra,56(sp)
    190e:	f822                	sd	s0,48(sp)
    1910:	f426                	sd	s1,40(sp)
    1912:	f04a                	sd	s2,32(sp)
    1914:	ec4e                	sd	s3,24(sp)
    1916:	e852                	sd	s4,16(sp)
    1918:	0080                	addi	s0,sp,64
    191a:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    191c:	4901                	li	s2,0
    191e:	06400993          	li	s3,100
    pid = fork();
    1922:	00004097          	auipc	ra,0x4
    1926:	db6080e7          	jalr	-586(ra) # 56d8 <fork>
    192a:	84aa                	mv	s1,a0
    if(pid < 0){
    192c:	02054a63          	bltz	a0,1960 <exitwait+0x56>
    if(pid){
    1930:	c151                	beqz	a0,19b4 <exitwait+0xaa>
      if(wait(&xstate) != pid){
    1932:	fcc40513          	addi	a0,s0,-52
    1936:	00004097          	auipc	ra,0x4
    193a:	db2080e7          	jalr	-590(ra) # 56e8 <wait>
    193e:	02951f63          	bne	a0,s1,197c <exitwait+0x72>
      if(i != xstate) {
    1942:	fcc42783          	lw	a5,-52(s0)
    1946:	05279963          	bne	a5,s2,1998 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    194a:	2905                	addiw	s2,s2,1
    194c:	fd391be3          	bne	s2,s3,1922 <exitwait+0x18>
}
    1950:	70e2                	ld	ra,56(sp)
    1952:	7442                	ld	s0,48(sp)
    1954:	74a2                	ld	s1,40(sp)
    1956:	7902                	ld	s2,32(sp)
    1958:	69e2                	ld	s3,24(sp)
    195a:	6a42                	ld	s4,16(sp)
    195c:	6121                	addi	sp,sp,64
    195e:	8082                	ret
      printf("%s: fork failed\n", s);
    1960:	85d2                	mv	a1,s4
    1962:	00005517          	auipc	a0,0x5
    1966:	e3e50513          	addi	a0,a0,-450 # 67a0 <malloc+0xc8a>
    196a:	00004097          	auipc	ra,0x4
    196e:	0ee080e7          	jalr	238(ra) # 5a58 <printf>
      exit(1);
    1972:	4505                	li	a0,1
    1974:	00004097          	auipc	ra,0x4
    1978:	d6c080e7          	jalr	-660(ra) # 56e0 <exit>
        printf("%s: wait wrong pid\n", s);
    197c:	85d2                	mv	a1,s4
    197e:	00005517          	auipc	a0,0x5
    1982:	faa50513          	addi	a0,a0,-86 # 6928 <malloc+0xe12>
    1986:	00004097          	auipc	ra,0x4
    198a:	0d2080e7          	jalr	210(ra) # 5a58 <printf>
        exit(1);
    198e:	4505                	li	a0,1
    1990:	00004097          	auipc	ra,0x4
    1994:	d50080e7          	jalr	-688(ra) # 56e0 <exit>
        printf("%s: wait wrong exit status\n", s);
    1998:	85d2                	mv	a1,s4
    199a:	00005517          	auipc	a0,0x5
    199e:	fa650513          	addi	a0,a0,-90 # 6940 <malloc+0xe2a>
    19a2:	00004097          	auipc	ra,0x4
    19a6:	0b6080e7          	jalr	182(ra) # 5a58 <printf>
        exit(1);
    19aa:	4505                	li	a0,1
    19ac:	00004097          	auipc	ra,0x4
    19b0:	d34080e7          	jalr	-716(ra) # 56e0 <exit>
      exit(i);
    19b4:	854a                	mv	a0,s2
    19b6:	00004097          	auipc	ra,0x4
    19ba:	d2a080e7          	jalr	-726(ra) # 56e0 <exit>

00000000000019be <twochildren>:
{
    19be:	1101                	addi	sp,sp,-32
    19c0:	ec06                	sd	ra,24(sp)
    19c2:	e822                	sd	s0,16(sp)
    19c4:	e426                	sd	s1,8(sp)
    19c6:	e04a                	sd	s2,0(sp)
    19c8:	1000                	addi	s0,sp,32
    19ca:	892a                	mv	s2,a0
    19cc:	3e800493          	li	s1,1000
    int pid1 = fork();
    19d0:	00004097          	auipc	ra,0x4
    19d4:	d08080e7          	jalr	-760(ra) # 56d8 <fork>
    if(pid1 < 0){
    19d8:	02054c63          	bltz	a0,1a10 <twochildren+0x52>
    if(pid1 == 0){
    19dc:	c921                	beqz	a0,1a2c <twochildren+0x6e>
      int pid2 = fork();
    19de:	00004097          	auipc	ra,0x4
    19e2:	cfa080e7          	jalr	-774(ra) # 56d8 <fork>
      if(pid2 < 0){
    19e6:	04054763          	bltz	a0,1a34 <twochildren+0x76>
      if(pid2 == 0){
    19ea:	c13d                	beqz	a0,1a50 <twochildren+0x92>
        wait(0);
    19ec:	4501                	li	a0,0
    19ee:	00004097          	auipc	ra,0x4
    19f2:	cfa080e7          	jalr	-774(ra) # 56e8 <wait>
        wait(0);
    19f6:	4501                	li	a0,0
    19f8:	00004097          	auipc	ra,0x4
    19fc:	cf0080e7          	jalr	-784(ra) # 56e8 <wait>
  for(int i = 0; i < 1000; i++){
    1a00:	34fd                	addiw	s1,s1,-1
    1a02:	f4f9                	bnez	s1,19d0 <twochildren+0x12>
}
    1a04:	60e2                	ld	ra,24(sp)
    1a06:	6442                	ld	s0,16(sp)
    1a08:	64a2                	ld	s1,8(sp)
    1a0a:	6902                	ld	s2,0(sp)
    1a0c:	6105                	addi	sp,sp,32
    1a0e:	8082                	ret
      printf("%s: fork failed\n", s);
    1a10:	85ca                	mv	a1,s2
    1a12:	00005517          	auipc	a0,0x5
    1a16:	d8e50513          	addi	a0,a0,-626 # 67a0 <malloc+0xc8a>
    1a1a:	00004097          	auipc	ra,0x4
    1a1e:	03e080e7          	jalr	62(ra) # 5a58 <printf>
      exit(1);
    1a22:	4505                	li	a0,1
    1a24:	00004097          	auipc	ra,0x4
    1a28:	cbc080e7          	jalr	-836(ra) # 56e0 <exit>
      exit(0);
    1a2c:	00004097          	auipc	ra,0x4
    1a30:	cb4080e7          	jalr	-844(ra) # 56e0 <exit>
        printf("%s: fork failed\n", s);
    1a34:	85ca                	mv	a1,s2
    1a36:	00005517          	auipc	a0,0x5
    1a3a:	d6a50513          	addi	a0,a0,-662 # 67a0 <malloc+0xc8a>
    1a3e:	00004097          	auipc	ra,0x4
    1a42:	01a080e7          	jalr	26(ra) # 5a58 <printf>
        exit(1);
    1a46:	4505                	li	a0,1
    1a48:	00004097          	auipc	ra,0x4
    1a4c:	c98080e7          	jalr	-872(ra) # 56e0 <exit>
        exit(0);
    1a50:	00004097          	auipc	ra,0x4
    1a54:	c90080e7          	jalr	-880(ra) # 56e0 <exit>

0000000000001a58 <forkfork>:
{
    1a58:	7179                	addi	sp,sp,-48
    1a5a:	f406                	sd	ra,40(sp)
    1a5c:	f022                	sd	s0,32(sp)
    1a5e:	ec26                	sd	s1,24(sp)
    1a60:	1800                	addi	s0,sp,48
    1a62:	84aa                	mv	s1,a0
    int pid = fork();
    1a64:	00004097          	auipc	ra,0x4
    1a68:	c74080e7          	jalr	-908(ra) # 56d8 <fork>
    if(pid < 0){
    1a6c:	04054163          	bltz	a0,1aae <forkfork+0x56>
    if(pid == 0){
    1a70:	cd29                	beqz	a0,1aca <forkfork+0x72>
    int pid = fork();
    1a72:	00004097          	auipc	ra,0x4
    1a76:	c66080e7          	jalr	-922(ra) # 56d8 <fork>
    if(pid < 0){
    1a7a:	02054a63          	bltz	a0,1aae <forkfork+0x56>
    if(pid == 0){
    1a7e:	c531                	beqz	a0,1aca <forkfork+0x72>
    wait(&xstatus);
    1a80:	fdc40513          	addi	a0,s0,-36
    1a84:	00004097          	auipc	ra,0x4
    1a88:	c64080e7          	jalr	-924(ra) # 56e8 <wait>
    if(xstatus != 0) {
    1a8c:	fdc42783          	lw	a5,-36(s0)
    1a90:	ebbd                	bnez	a5,1b06 <forkfork+0xae>
    wait(&xstatus);
    1a92:	fdc40513          	addi	a0,s0,-36
    1a96:	00004097          	auipc	ra,0x4
    1a9a:	c52080e7          	jalr	-942(ra) # 56e8 <wait>
    if(xstatus != 0) {
    1a9e:	fdc42783          	lw	a5,-36(s0)
    1aa2:	e3b5                	bnez	a5,1b06 <forkfork+0xae>
}
    1aa4:	70a2                	ld	ra,40(sp)
    1aa6:	7402                	ld	s0,32(sp)
    1aa8:	64e2                	ld	s1,24(sp)
    1aaa:	6145                	addi	sp,sp,48
    1aac:	8082                	ret
      printf("%s: fork failed", s);
    1aae:	85a6                	mv	a1,s1
    1ab0:	00005517          	auipc	a0,0x5
    1ab4:	eb050513          	addi	a0,a0,-336 # 6960 <malloc+0xe4a>
    1ab8:	00004097          	auipc	ra,0x4
    1abc:	fa0080e7          	jalr	-96(ra) # 5a58 <printf>
      exit(1);
    1ac0:	4505                	li	a0,1
    1ac2:	00004097          	auipc	ra,0x4
    1ac6:	c1e080e7          	jalr	-994(ra) # 56e0 <exit>
{
    1aca:	0c800493          	li	s1,200
        int pid1 = fork();
    1ace:	00004097          	auipc	ra,0x4
    1ad2:	c0a080e7          	jalr	-1014(ra) # 56d8 <fork>
        if(pid1 < 0){
    1ad6:	00054f63          	bltz	a0,1af4 <forkfork+0x9c>
        if(pid1 == 0){
    1ada:	c115                	beqz	a0,1afe <forkfork+0xa6>
        wait(0);
    1adc:	4501                	li	a0,0
    1ade:	00004097          	auipc	ra,0x4
    1ae2:	c0a080e7          	jalr	-1014(ra) # 56e8 <wait>
      for(int j = 0; j < 200; j++){
    1ae6:	34fd                	addiw	s1,s1,-1
    1ae8:	f0fd                	bnez	s1,1ace <forkfork+0x76>
      exit(0);
    1aea:	4501                	li	a0,0
    1aec:	00004097          	auipc	ra,0x4
    1af0:	bf4080e7          	jalr	-1036(ra) # 56e0 <exit>
          exit(1);
    1af4:	4505                	li	a0,1
    1af6:	00004097          	auipc	ra,0x4
    1afa:	bea080e7          	jalr	-1046(ra) # 56e0 <exit>
          exit(0);
    1afe:	00004097          	auipc	ra,0x4
    1b02:	be2080e7          	jalr	-1054(ra) # 56e0 <exit>
      printf("%s: fork in child failed", s);
    1b06:	85a6                	mv	a1,s1
    1b08:	00005517          	auipc	a0,0x5
    1b0c:	e6850513          	addi	a0,a0,-408 # 6970 <malloc+0xe5a>
    1b10:	00004097          	auipc	ra,0x4
    1b14:	f48080e7          	jalr	-184(ra) # 5a58 <printf>
      exit(1);
    1b18:	4505                	li	a0,1
    1b1a:	00004097          	auipc	ra,0x4
    1b1e:	bc6080e7          	jalr	-1082(ra) # 56e0 <exit>

0000000000001b22 <reparent2>:
{
    1b22:	1101                	addi	sp,sp,-32
    1b24:	ec06                	sd	ra,24(sp)
    1b26:	e822                	sd	s0,16(sp)
    1b28:	e426                	sd	s1,8(sp)
    1b2a:	1000                	addi	s0,sp,32
    1b2c:	32000493          	li	s1,800
    int pid1 = fork();
    1b30:	00004097          	auipc	ra,0x4
    1b34:	ba8080e7          	jalr	-1112(ra) # 56d8 <fork>
    if(pid1 < 0){
    1b38:	00054f63          	bltz	a0,1b56 <reparent2+0x34>
    if(pid1 == 0){
    1b3c:	c915                	beqz	a0,1b70 <reparent2+0x4e>
    wait(0);
    1b3e:	4501                	li	a0,0
    1b40:	00004097          	auipc	ra,0x4
    1b44:	ba8080e7          	jalr	-1112(ra) # 56e8 <wait>
  for(int i = 0; i < 800; i++){
    1b48:	34fd                	addiw	s1,s1,-1
    1b4a:	f0fd                	bnez	s1,1b30 <reparent2+0xe>
  exit(0);
    1b4c:	4501                	li	a0,0
    1b4e:	00004097          	auipc	ra,0x4
    1b52:	b92080e7          	jalr	-1134(ra) # 56e0 <exit>
      printf("fork failed\n");
    1b56:	00005517          	auipc	a0,0x5
    1b5a:	05250513          	addi	a0,a0,82 # 6ba8 <malloc+0x1092>
    1b5e:	00004097          	auipc	ra,0x4
    1b62:	efa080e7          	jalr	-262(ra) # 5a58 <printf>
      exit(1);
    1b66:	4505                	li	a0,1
    1b68:	00004097          	auipc	ra,0x4
    1b6c:	b78080e7          	jalr	-1160(ra) # 56e0 <exit>
      fork();
    1b70:	00004097          	auipc	ra,0x4
    1b74:	b68080e7          	jalr	-1176(ra) # 56d8 <fork>
      fork();
    1b78:	00004097          	auipc	ra,0x4
    1b7c:	b60080e7          	jalr	-1184(ra) # 56d8 <fork>
      exit(0);
    1b80:	4501                	li	a0,0
    1b82:	00004097          	auipc	ra,0x4
    1b86:	b5e080e7          	jalr	-1186(ra) # 56e0 <exit>

0000000000001b8a <createdelete>:
{
    1b8a:	7175                	addi	sp,sp,-144
    1b8c:	e506                	sd	ra,136(sp)
    1b8e:	e122                	sd	s0,128(sp)
    1b90:	fca6                	sd	s1,120(sp)
    1b92:	f8ca                	sd	s2,112(sp)
    1b94:	f4ce                	sd	s3,104(sp)
    1b96:	f0d2                	sd	s4,96(sp)
    1b98:	ecd6                	sd	s5,88(sp)
    1b9a:	e8da                	sd	s6,80(sp)
    1b9c:	e4de                	sd	s7,72(sp)
    1b9e:	e0e2                	sd	s8,64(sp)
    1ba0:	fc66                	sd	s9,56(sp)
    1ba2:	0900                	addi	s0,sp,144
    1ba4:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1ba6:	4901                	li	s2,0
    1ba8:	4991                	li	s3,4
    pid = fork();
    1baa:	00004097          	auipc	ra,0x4
    1bae:	b2e080e7          	jalr	-1234(ra) # 56d8 <fork>
    1bb2:	84aa                	mv	s1,a0
    if(pid < 0){
    1bb4:	02054f63          	bltz	a0,1bf2 <createdelete+0x68>
    if(pid == 0){
    1bb8:	c939                	beqz	a0,1c0e <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1bba:	2905                	addiw	s2,s2,1
    1bbc:	ff3917e3          	bne	s2,s3,1baa <createdelete+0x20>
    1bc0:	4491                	li	s1,4
    wait(&xstatus);
    1bc2:	f7c40513          	addi	a0,s0,-132
    1bc6:	00004097          	auipc	ra,0x4
    1bca:	b22080e7          	jalr	-1246(ra) # 56e8 <wait>
    if(xstatus != 0)
    1bce:	f7c42903          	lw	s2,-132(s0)
    1bd2:	0e091263          	bnez	s2,1cb6 <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1bd6:	34fd                	addiw	s1,s1,-1
    1bd8:	f4ed                	bnez	s1,1bc2 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1bda:	f8040123          	sb	zero,-126(s0)
    1bde:	03000993          	li	s3,48
    1be2:	5a7d                	li	s4,-1
    1be4:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1be8:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1bea:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1bec:	07400a93          	li	s5,116
    1bf0:	a29d                	j	1d56 <createdelete+0x1cc>
      printf("fork failed\n", s);
    1bf2:	85e6                	mv	a1,s9
    1bf4:	00005517          	auipc	a0,0x5
    1bf8:	fb450513          	addi	a0,a0,-76 # 6ba8 <malloc+0x1092>
    1bfc:	00004097          	auipc	ra,0x4
    1c00:	e5c080e7          	jalr	-420(ra) # 5a58 <printf>
      exit(1);
    1c04:	4505                	li	a0,1
    1c06:	00004097          	auipc	ra,0x4
    1c0a:	ada080e7          	jalr	-1318(ra) # 56e0 <exit>
      name[0] = 'p' + pi;
    1c0e:	0709091b          	addiw	s2,s2,112
    1c12:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1c16:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1c1a:	4951                	li	s2,20
    1c1c:	a015                	j	1c40 <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1c1e:	85e6                	mv	a1,s9
    1c20:	00005517          	auipc	a0,0x5
    1c24:	c1850513          	addi	a0,a0,-1000 # 6838 <malloc+0xd22>
    1c28:	00004097          	auipc	ra,0x4
    1c2c:	e30080e7          	jalr	-464(ra) # 5a58 <printf>
          exit(1);
    1c30:	4505                	li	a0,1
    1c32:	00004097          	auipc	ra,0x4
    1c36:	aae080e7          	jalr	-1362(ra) # 56e0 <exit>
      for(i = 0; i < N; i++){
    1c3a:	2485                	addiw	s1,s1,1
    1c3c:	07248863          	beq	s1,s2,1cac <createdelete+0x122>
        name[1] = '0' + i;
    1c40:	0304879b          	addiw	a5,s1,48
    1c44:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1c48:	20200593          	li	a1,514
    1c4c:	f8040513          	addi	a0,s0,-128
    1c50:	00004097          	auipc	ra,0x4
    1c54:	ad0080e7          	jalr	-1328(ra) # 5720 <open>
        if(fd < 0){
    1c58:	fc0543e3          	bltz	a0,1c1e <createdelete+0x94>
        close(fd);
    1c5c:	00004097          	auipc	ra,0x4
    1c60:	aac080e7          	jalr	-1364(ra) # 5708 <close>
        if(i > 0 && (i % 2 ) == 0){
    1c64:	fc905be3          	blez	s1,1c3a <createdelete+0xb0>
    1c68:	0014f793          	andi	a5,s1,1
    1c6c:	f7f9                	bnez	a5,1c3a <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1c6e:	01f4d79b          	srliw	a5,s1,0x1f
    1c72:	9fa5                	addw	a5,a5,s1
    1c74:	4017d79b          	sraiw	a5,a5,0x1
    1c78:	0307879b          	addiw	a5,a5,48
    1c7c:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1c80:	f8040513          	addi	a0,s0,-128
    1c84:	00004097          	auipc	ra,0x4
    1c88:	aac080e7          	jalr	-1364(ra) # 5730 <unlink>
    1c8c:	fa0557e3          	bgez	a0,1c3a <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1c90:	85e6                	mv	a1,s9
    1c92:	00005517          	auipc	a0,0x5
    1c96:	cfe50513          	addi	a0,a0,-770 # 6990 <malloc+0xe7a>
    1c9a:	00004097          	auipc	ra,0x4
    1c9e:	dbe080e7          	jalr	-578(ra) # 5a58 <printf>
            exit(1);
    1ca2:	4505                	li	a0,1
    1ca4:	00004097          	auipc	ra,0x4
    1ca8:	a3c080e7          	jalr	-1476(ra) # 56e0 <exit>
      exit(0);
    1cac:	4501                	li	a0,0
    1cae:	00004097          	auipc	ra,0x4
    1cb2:	a32080e7          	jalr	-1486(ra) # 56e0 <exit>
      exit(1);
    1cb6:	4505                	li	a0,1
    1cb8:	00004097          	auipc	ra,0x4
    1cbc:	a28080e7          	jalr	-1496(ra) # 56e0 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1cc0:	f8040613          	addi	a2,s0,-128
    1cc4:	85e6                	mv	a1,s9
    1cc6:	00005517          	auipc	a0,0x5
    1cca:	ce250513          	addi	a0,a0,-798 # 69a8 <malloc+0xe92>
    1cce:	00004097          	auipc	ra,0x4
    1cd2:	d8a080e7          	jalr	-630(ra) # 5a58 <printf>
        exit(1);
    1cd6:	4505                	li	a0,1
    1cd8:	00004097          	auipc	ra,0x4
    1cdc:	a08080e7          	jalr	-1528(ra) # 56e0 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1ce0:	054b7163          	bgeu	s6,s4,1d22 <createdelete+0x198>
      if(fd >= 0)
    1ce4:	02055a63          	bgez	a0,1d18 <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1ce8:	2485                	addiw	s1,s1,1
    1cea:	0ff4f493          	andi	s1,s1,255
    1cee:	05548c63          	beq	s1,s5,1d46 <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1cf2:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1cf6:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1cfa:	4581                	li	a1,0
    1cfc:	f8040513          	addi	a0,s0,-128
    1d00:	00004097          	auipc	ra,0x4
    1d04:	a20080e7          	jalr	-1504(ra) # 5720 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1d08:	00090463          	beqz	s2,1d10 <createdelete+0x186>
    1d0c:	fd2bdae3          	bge	s7,s2,1ce0 <createdelete+0x156>
    1d10:	fa0548e3          	bltz	a0,1cc0 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d14:	014b7963          	bgeu	s6,s4,1d26 <createdelete+0x19c>
        close(fd);
    1d18:	00004097          	auipc	ra,0x4
    1d1c:	9f0080e7          	jalr	-1552(ra) # 5708 <close>
    1d20:	b7e1                	j	1ce8 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d22:	fc0543e3          	bltz	a0,1ce8 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1d26:	f8040613          	addi	a2,s0,-128
    1d2a:	85e6                	mv	a1,s9
    1d2c:	00005517          	auipc	a0,0x5
    1d30:	ca450513          	addi	a0,a0,-860 # 69d0 <malloc+0xeba>
    1d34:	00004097          	auipc	ra,0x4
    1d38:	d24080e7          	jalr	-732(ra) # 5a58 <printf>
        exit(1);
    1d3c:	4505                	li	a0,1
    1d3e:	00004097          	auipc	ra,0x4
    1d42:	9a2080e7          	jalr	-1630(ra) # 56e0 <exit>
  for(i = 0; i < N; i++){
    1d46:	2905                	addiw	s2,s2,1
    1d48:	2a05                	addiw	s4,s4,1
    1d4a:	2985                	addiw	s3,s3,1
    1d4c:	0ff9f993          	andi	s3,s3,255
    1d50:	47d1                	li	a5,20
    1d52:	02f90a63          	beq	s2,a5,1d86 <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1d56:	84e2                	mv	s1,s8
    1d58:	bf69                	j	1cf2 <createdelete+0x168>
  for(i = 0; i < N; i++){
    1d5a:	2905                	addiw	s2,s2,1
    1d5c:	0ff97913          	andi	s2,s2,255
    1d60:	2985                	addiw	s3,s3,1
    1d62:	0ff9f993          	andi	s3,s3,255
    1d66:	03490863          	beq	s2,s4,1d96 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1d6a:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1d6c:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1d70:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1d74:	f8040513          	addi	a0,s0,-128
    1d78:	00004097          	auipc	ra,0x4
    1d7c:	9b8080e7          	jalr	-1608(ra) # 5730 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1d80:	34fd                	addiw	s1,s1,-1
    1d82:	f4ed                	bnez	s1,1d6c <createdelete+0x1e2>
    1d84:	bfd9                	j	1d5a <createdelete+0x1d0>
    1d86:	03000993          	li	s3,48
    1d8a:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1d8e:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1d90:	08400a13          	li	s4,132
    1d94:	bfd9                	j	1d6a <createdelete+0x1e0>
}
    1d96:	60aa                	ld	ra,136(sp)
    1d98:	640a                	ld	s0,128(sp)
    1d9a:	74e6                	ld	s1,120(sp)
    1d9c:	7946                	ld	s2,112(sp)
    1d9e:	79a6                	ld	s3,104(sp)
    1da0:	7a06                	ld	s4,96(sp)
    1da2:	6ae6                	ld	s5,88(sp)
    1da4:	6b46                	ld	s6,80(sp)
    1da6:	6ba6                	ld	s7,72(sp)
    1da8:	6c06                	ld	s8,64(sp)
    1daa:	7ce2                	ld	s9,56(sp)
    1dac:	6149                	addi	sp,sp,144
    1dae:	8082                	ret

0000000000001db0 <linkunlink>:
{
    1db0:	711d                	addi	sp,sp,-96
    1db2:	ec86                	sd	ra,88(sp)
    1db4:	e8a2                	sd	s0,80(sp)
    1db6:	e4a6                	sd	s1,72(sp)
    1db8:	e0ca                	sd	s2,64(sp)
    1dba:	fc4e                	sd	s3,56(sp)
    1dbc:	f852                	sd	s4,48(sp)
    1dbe:	f456                	sd	s5,40(sp)
    1dc0:	f05a                	sd	s6,32(sp)
    1dc2:	ec5e                	sd	s7,24(sp)
    1dc4:	e862                	sd	s8,16(sp)
    1dc6:	e466                	sd	s9,8(sp)
    1dc8:	1080                	addi	s0,sp,96
    1dca:	84aa                	mv	s1,a0
  unlink("x");
    1dcc:	00004517          	auipc	a0,0x4
    1dd0:	20c50513          	addi	a0,a0,524 # 5fd8 <malloc+0x4c2>
    1dd4:	00004097          	auipc	ra,0x4
    1dd8:	95c080e7          	jalr	-1700(ra) # 5730 <unlink>
  pid = fork();
    1ddc:	00004097          	auipc	ra,0x4
    1de0:	8fc080e7          	jalr	-1796(ra) # 56d8 <fork>
  if(pid < 0){
    1de4:	02054b63          	bltz	a0,1e1a <linkunlink+0x6a>
    1de8:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1dea:	4c85                	li	s9,1
    1dec:	e119                	bnez	a0,1df2 <linkunlink+0x42>
    1dee:	06100c93          	li	s9,97
    1df2:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1df6:	41c659b7          	lui	s3,0x41c65
    1dfa:	e6d9899b          	addiw	s3,s3,-403
    1dfe:	690d                	lui	s2,0x3
    1e00:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    1e04:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1e06:	4b05                	li	s6,1
      unlink("x");
    1e08:	00004a97          	auipc	s5,0x4
    1e0c:	1d0a8a93          	addi	s5,s5,464 # 5fd8 <malloc+0x4c2>
      link("cat", "x");
    1e10:	00005b97          	auipc	s7,0x5
    1e14:	be8b8b93          	addi	s7,s7,-1048 # 69f8 <malloc+0xee2>
    1e18:	a825                	j	1e50 <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    1e1a:	85a6                	mv	a1,s1
    1e1c:	00005517          	auipc	a0,0x5
    1e20:	98450513          	addi	a0,a0,-1660 # 67a0 <malloc+0xc8a>
    1e24:	00004097          	auipc	ra,0x4
    1e28:	c34080e7          	jalr	-972(ra) # 5a58 <printf>
    exit(1);
    1e2c:	4505                	li	a0,1
    1e2e:	00004097          	auipc	ra,0x4
    1e32:	8b2080e7          	jalr	-1870(ra) # 56e0 <exit>
      close(open("x", O_RDWR | O_CREATE));
    1e36:	20200593          	li	a1,514
    1e3a:	8556                	mv	a0,s5
    1e3c:	00004097          	auipc	ra,0x4
    1e40:	8e4080e7          	jalr	-1820(ra) # 5720 <open>
    1e44:	00004097          	auipc	ra,0x4
    1e48:	8c4080e7          	jalr	-1852(ra) # 5708 <close>
  for(i = 0; i < 100; i++){
    1e4c:	34fd                	addiw	s1,s1,-1
    1e4e:	c88d                	beqz	s1,1e80 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    1e50:	033c87bb          	mulw	a5,s9,s3
    1e54:	012787bb          	addw	a5,a5,s2
    1e58:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    1e5c:	0347f7bb          	remuw	a5,a5,s4
    1e60:	dbf9                	beqz	a5,1e36 <linkunlink+0x86>
    } else if((x % 3) == 1){
    1e62:	01678863          	beq	a5,s6,1e72 <linkunlink+0xc2>
      unlink("x");
    1e66:	8556                	mv	a0,s5
    1e68:	00004097          	auipc	ra,0x4
    1e6c:	8c8080e7          	jalr	-1848(ra) # 5730 <unlink>
    1e70:	bff1                	j	1e4c <linkunlink+0x9c>
      link("cat", "x");
    1e72:	85d6                	mv	a1,s5
    1e74:	855e                	mv	a0,s7
    1e76:	00004097          	auipc	ra,0x4
    1e7a:	8ca080e7          	jalr	-1846(ra) # 5740 <link>
    1e7e:	b7f9                	j	1e4c <linkunlink+0x9c>
  if(pid)
    1e80:	020c0463          	beqz	s8,1ea8 <linkunlink+0xf8>
    wait(0);
    1e84:	4501                	li	a0,0
    1e86:	00004097          	auipc	ra,0x4
    1e8a:	862080e7          	jalr	-1950(ra) # 56e8 <wait>
}
    1e8e:	60e6                	ld	ra,88(sp)
    1e90:	6446                	ld	s0,80(sp)
    1e92:	64a6                	ld	s1,72(sp)
    1e94:	6906                	ld	s2,64(sp)
    1e96:	79e2                	ld	s3,56(sp)
    1e98:	7a42                	ld	s4,48(sp)
    1e9a:	7aa2                	ld	s5,40(sp)
    1e9c:	7b02                	ld	s6,32(sp)
    1e9e:	6be2                	ld	s7,24(sp)
    1ea0:	6c42                	ld	s8,16(sp)
    1ea2:	6ca2                	ld	s9,8(sp)
    1ea4:	6125                	addi	sp,sp,96
    1ea6:	8082                	ret
    exit(0);
    1ea8:	4501                	li	a0,0
    1eaa:	00004097          	auipc	ra,0x4
    1eae:	836080e7          	jalr	-1994(ra) # 56e0 <exit>

0000000000001eb2 <manywrites>:
{
    1eb2:	711d                	addi	sp,sp,-96
    1eb4:	ec86                	sd	ra,88(sp)
    1eb6:	e8a2                	sd	s0,80(sp)
    1eb8:	e4a6                	sd	s1,72(sp)
    1eba:	e0ca                	sd	s2,64(sp)
    1ebc:	fc4e                	sd	s3,56(sp)
    1ebe:	f852                	sd	s4,48(sp)
    1ec0:	f456                	sd	s5,40(sp)
    1ec2:	f05a                	sd	s6,32(sp)
    1ec4:	ec5e                	sd	s7,24(sp)
    1ec6:	1080                	addi	s0,sp,96
    1ec8:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    1eca:	4981                	li	s3,0
    1ecc:	4911                	li	s2,4
    int pid = fork();
    1ece:	00004097          	auipc	ra,0x4
    1ed2:	80a080e7          	jalr	-2038(ra) # 56d8 <fork>
    1ed6:	84aa                	mv	s1,a0
    if(pid < 0){
    1ed8:	02054963          	bltz	a0,1f0a <manywrites+0x58>
    if(pid == 0){
    1edc:	c521                	beqz	a0,1f24 <manywrites+0x72>
  for(int ci = 0; ci < nchildren; ci++){
    1ede:	2985                	addiw	s3,s3,1
    1ee0:	ff2997e3          	bne	s3,s2,1ece <manywrites+0x1c>
    1ee4:	4491                	li	s1,4
    int st = 0;
    1ee6:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    1eea:	fa840513          	addi	a0,s0,-88
    1eee:	00003097          	auipc	ra,0x3
    1ef2:	7fa080e7          	jalr	2042(ra) # 56e8 <wait>
    if(st != 0)
    1ef6:	fa842503          	lw	a0,-88(s0)
    1efa:	ed6d                	bnez	a0,1ff4 <manywrites+0x142>
  for(int ci = 0; ci < nchildren; ci++){
    1efc:	34fd                	addiw	s1,s1,-1
    1efe:	f4e5                	bnez	s1,1ee6 <manywrites+0x34>
  exit(0);
    1f00:	4501                	li	a0,0
    1f02:	00003097          	auipc	ra,0x3
    1f06:	7de080e7          	jalr	2014(ra) # 56e0 <exit>
      printf("fork failed\n");
    1f0a:	00005517          	auipc	a0,0x5
    1f0e:	c9e50513          	addi	a0,a0,-866 # 6ba8 <malloc+0x1092>
    1f12:	00004097          	auipc	ra,0x4
    1f16:	b46080e7          	jalr	-1210(ra) # 5a58 <printf>
      exit(1);
    1f1a:	4505                	li	a0,1
    1f1c:	00003097          	auipc	ra,0x3
    1f20:	7c4080e7          	jalr	1988(ra) # 56e0 <exit>
      name[0] = 'b';
    1f24:	06200793          	li	a5,98
    1f28:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    1f2c:	0619879b          	addiw	a5,s3,97
    1f30:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    1f34:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    1f38:	fa840513          	addi	a0,s0,-88
    1f3c:	00003097          	auipc	ra,0x3
    1f40:	7f4080e7          	jalr	2036(ra) # 5730 <unlink>
    1f44:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    1f46:	0000ab17          	auipc	s6,0xa
    1f4a:	c8ab0b13          	addi	s6,s6,-886 # bbd0 <buf>
        for(int i = 0; i < ci+1; i++){
    1f4e:	8a26                	mv	s4,s1
    1f50:	0209ce63          	bltz	s3,1f8c <manywrites+0xda>
          int fd = open(name, O_CREATE | O_RDWR);
    1f54:	20200593          	li	a1,514
    1f58:	fa840513          	addi	a0,s0,-88
    1f5c:	00003097          	auipc	ra,0x3
    1f60:	7c4080e7          	jalr	1988(ra) # 5720 <open>
    1f64:	892a                	mv	s2,a0
          if(fd < 0){
    1f66:	04054763          	bltz	a0,1fb4 <manywrites+0x102>
          int cc = write(fd, buf, sz);
    1f6a:	660d                	lui	a2,0x3
    1f6c:	85da                	mv	a1,s6
    1f6e:	00003097          	auipc	ra,0x3
    1f72:	792080e7          	jalr	1938(ra) # 5700 <write>
          if(cc != sz){
    1f76:	678d                	lui	a5,0x3
    1f78:	04f51e63          	bne	a0,a5,1fd4 <manywrites+0x122>
          close(fd);
    1f7c:	854a                	mv	a0,s2
    1f7e:	00003097          	auipc	ra,0x3
    1f82:	78a080e7          	jalr	1930(ra) # 5708 <close>
        for(int i = 0; i < ci+1; i++){
    1f86:	2a05                	addiw	s4,s4,1
    1f88:	fd49d6e3          	bge	s3,s4,1f54 <manywrites+0xa2>
        unlink(name);
    1f8c:	fa840513          	addi	a0,s0,-88
    1f90:	00003097          	auipc	ra,0x3
    1f94:	7a0080e7          	jalr	1952(ra) # 5730 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    1f98:	3bfd                	addiw	s7,s7,-1
    1f9a:	fa0b9ae3          	bnez	s7,1f4e <manywrites+0x9c>
      unlink(name);
    1f9e:	fa840513          	addi	a0,s0,-88
    1fa2:	00003097          	auipc	ra,0x3
    1fa6:	78e080e7          	jalr	1934(ra) # 5730 <unlink>
      exit(0);
    1faa:	4501                	li	a0,0
    1fac:	00003097          	auipc	ra,0x3
    1fb0:	734080e7          	jalr	1844(ra) # 56e0 <exit>
            printf("%s: cannot create %s\n", s, name);
    1fb4:	fa840613          	addi	a2,s0,-88
    1fb8:	85d6                	mv	a1,s5
    1fba:	00005517          	auipc	a0,0x5
    1fbe:	a4650513          	addi	a0,a0,-1466 # 6a00 <malloc+0xeea>
    1fc2:	00004097          	auipc	ra,0x4
    1fc6:	a96080e7          	jalr	-1386(ra) # 5a58 <printf>
            exit(1);
    1fca:	4505                	li	a0,1
    1fcc:	00003097          	auipc	ra,0x3
    1fd0:	714080e7          	jalr	1812(ra) # 56e0 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    1fd4:	86aa                	mv	a3,a0
    1fd6:	660d                	lui	a2,0x3
    1fd8:	85d6                	mv	a1,s5
    1fda:	00004517          	auipc	a0,0x4
    1fde:	04e50513          	addi	a0,a0,78 # 6028 <malloc+0x512>
    1fe2:	00004097          	auipc	ra,0x4
    1fe6:	a76080e7          	jalr	-1418(ra) # 5a58 <printf>
            exit(1);
    1fea:	4505                	li	a0,1
    1fec:	00003097          	auipc	ra,0x3
    1ff0:	6f4080e7          	jalr	1780(ra) # 56e0 <exit>
      exit(st);
    1ff4:	00003097          	auipc	ra,0x3
    1ff8:	6ec080e7          	jalr	1772(ra) # 56e0 <exit>

0000000000001ffc <forktest>:
{
    1ffc:	7179                	addi	sp,sp,-48
    1ffe:	f406                	sd	ra,40(sp)
    2000:	f022                	sd	s0,32(sp)
    2002:	ec26                	sd	s1,24(sp)
    2004:	e84a                	sd	s2,16(sp)
    2006:	e44e                	sd	s3,8(sp)
    2008:	1800                	addi	s0,sp,48
    200a:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    200c:	4481                	li	s1,0
    200e:	3e800913          	li	s2,1000
    pid = fork();
    2012:	00003097          	auipc	ra,0x3
    2016:	6c6080e7          	jalr	1734(ra) # 56d8 <fork>
    if(pid < 0)
    201a:	02054863          	bltz	a0,204a <forktest+0x4e>
    if(pid == 0)
    201e:	c115                	beqz	a0,2042 <forktest+0x46>
  for(n=0; n<N; n++){
    2020:	2485                	addiw	s1,s1,1
    2022:	ff2498e3          	bne	s1,s2,2012 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    2026:	85ce                	mv	a1,s3
    2028:	00005517          	auipc	a0,0x5
    202c:	a0850513          	addi	a0,a0,-1528 # 6a30 <malloc+0xf1a>
    2030:	00004097          	auipc	ra,0x4
    2034:	a28080e7          	jalr	-1496(ra) # 5a58 <printf>
    exit(1);
    2038:	4505                	li	a0,1
    203a:	00003097          	auipc	ra,0x3
    203e:	6a6080e7          	jalr	1702(ra) # 56e0 <exit>
      exit(0);
    2042:	00003097          	auipc	ra,0x3
    2046:	69e080e7          	jalr	1694(ra) # 56e0 <exit>
  if (n == 0) {
    204a:	cc9d                	beqz	s1,2088 <forktest+0x8c>
  if(n == N){
    204c:	3e800793          	li	a5,1000
    2050:	fcf48be3          	beq	s1,a5,2026 <forktest+0x2a>
  for(; n > 0; n--){
    2054:	00905b63          	blez	s1,206a <forktest+0x6e>
    if(wait(0) < 0){
    2058:	4501                	li	a0,0
    205a:	00003097          	auipc	ra,0x3
    205e:	68e080e7          	jalr	1678(ra) # 56e8 <wait>
    2062:	04054163          	bltz	a0,20a4 <forktest+0xa8>
  for(; n > 0; n--){
    2066:	34fd                	addiw	s1,s1,-1
    2068:	f8e5                	bnez	s1,2058 <forktest+0x5c>
  if(wait(0) != -1){
    206a:	4501                	li	a0,0
    206c:	00003097          	auipc	ra,0x3
    2070:	67c080e7          	jalr	1660(ra) # 56e8 <wait>
    2074:	57fd                	li	a5,-1
    2076:	04f51563          	bne	a0,a5,20c0 <forktest+0xc4>
}
    207a:	70a2                	ld	ra,40(sp)
    207c:	7402                	ld	s0,32(sp)
    207e:	64e2                	ld	s1,24(sp)
    2080:	6942                	ld	s2,16(sp)
    2082:	69a2                	ld	s3,8(sp)
    2084:	6145                	addi	sp,sp,48
    2086:	8082                	ret
    printf("%s: no fork at all!\n", s);
    2088:	85ce                	mv	a1,s3
    208a:	00005517          	auipc	a0,0x5
    208e:	98e50513          	addi	a0,a0,-1650 # 6a18 <malloc+0xf02>
    2092:	00004097          	auipc	ra,0x4
    2096:	9c6080e7          	jalr	-1594(ra) # 5a58 <printf>
    exit(1);
    209a:	4505                	li	a0,1
    209c:	00003097          	auipc	ra,0x3
    20a0:	644080e7          	jalr	1604(ra) # 56e0 <exit>
      printf("%s: wait stopped early\n", s);
    20a4:	85ce                	mv	a1,s3
    20a6:	00005517          	auipc	a0,0x5
    20aa:	9b250513          	addi	a0,a0,-1614 # 6a58 <malloc+0xf42>
    20ae:	00004097          	auipc	ra,0x4
    20b2:	9aa080e7          	jalr	-1622(ra) # 5a58 <printf>
      exit(1);
    20b6:	4505                	li	a0,1
    20b8:	00003097          	auipc	ra,0x3
    20bc:	628080e7          	jalr	1576(ra) # 56e0 <exit>
    printf("%s: wait got too many\n", s);
    20c0:	85ce                	mv	a1,s3
    20c2:	00005517          	auipc	a0,0x5
    20c6:	9ae50513          	addi	a0,a0,-1618 # 6a70 <malloc+0xf5a>
    20ca:	00004097          	auipc	ra,0x4
    20ce:	98e080e7          	jalr	-1650(ra) # 5a58 <printf>
    exit(1);
    20d2:	4505                	li	a0,1
    20d4:	00003097          	auipc	ra,0x3
    20d8:	60c080e7          	jalr	1548(ra) # 56e0 <exit>

00000000000020dc <kernmem>:
{
    20dc:	715d                	addi	sp,sp,-80
    20de:	e486                	sd	ra,72(sp)
    20e0:	e0a2                	sd	s0,64(sp)
    20e2:	fc26                	sd	s1,56(sp)
    20e4:	f84a                	sd	s2,48(sp)
    20e6:	f44e                	sd	s3,40(sp)
    20e8:	f052                	sd	s4,32(sp)
    20ea:	ec56                	sd	s5,24(sp)
    20ec:	0880                	addi	s0,sp,80
    20ee:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    20f0:	4485                	li	s1,1
    20f2:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    20f4:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    20f6:	69b1                	lui	s3,0xc
    20f8:	35098993          	addi	s3,s3,848 # c350 <buf+0x780>
    20fc:	1003d937          	lui	s2,0x1003d
    2100:	090e                	slli	s2,s2,0x3
    2102:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x1002e8a0>
    pid = fork();
    2106:	00003097          	auipc	ra,0x3
    210a:	5d2080e7          	jalr	1490(ra) # 56d8 <fork>
    if(pid < 0){
    210e:	02054963          	bltz	a0,2140 <kernmem+0x64>
    if(pid == 0){
    2112:	c529                	beqz	a0,215c <kernmem+0x80>
    wait(&xstatus);
    2114:	fbc40513          	addi	a0,s0,-68
    2118:	00003097          	auipc	ra,0x3
    211c:	5d0080e7          	jalr	1488(ra) # 56e8 <wait>
    if(xstatus != -1)  // did kernel kill child?
    2120:	fbc42783          	lw	a5,-68(s0)
    2124:	05579d63          	bne	a5,s5,217e <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2128:	94ce                	add	s1,s1,s3
    212a:	fd249ee3          	bne	s1,s2,2106 <kernmem+0x2a>
}
    212e:	60a6                	ld	ra,72(sp)
    2130:	6406                	ld	s0,64(sp)
    2132:	74e2                	ld	s1,56(sp)
    2134:	7942                	ld	s2,48(sp)
    2136:	79a2                	ld	s3,40(sp)
    2138:	7a02                	ld	s4,32(sp)
    213a:	6ae2                	ld	s5,24(sp)
    213c:	6161                	addi	sp,sp,80
    213e:	8082                	ret
      printf("%s: fork failed\n", s);
    2140:	85d2                	mv	a1,s4
    2142:	00004517          	auipc	a0,0x4
    2146:	65e50513          	addi	a0,a0,1630 # 67a0 <malloc+0xc8a>
    214a:	00004097          	auipc	ra,0x4
    214e:	90e080e7          	jalr	-1778(ra) # 5a58 <printf>
      exit(1);
    2152:	4505                	li	a0,1
    2154:	00003097          	auipc	ra,0x3
    2158:	58c080e7          	jalr	1420(ra) # 56e0 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    215c:	0004c683          	lbu	a3,0(s1)
    2160:	8626                	mv	a2,s1
    2162:	85d2                	mv	a1,s4
    2164:	00005517          	auipc	a0,0x5
    2168:	92450513          	addi	a0,a0,-1756 # 6a88 <malloc+0xf72>
    216c:	00004097          	auipc	ra,0x4
    2170:	8ec080e7          	jalr	-1812(ra) # 5a58 <printf>
      exit(1);
    2174:	4505                	li	a0,1
    2176:	00003097          	auipc	ra,0x3
    217a:	56a080e7          	jalr	1386(ra) # 56e0 <exit>
      exit(1);
    217e:	4505                	li	a0,1
    2180:	00003097          	auipc	ra,0x3
    2184:	560080e7          	jalr	1376(ra) # 56e0 <exit>

0000000000002188 <bigargtest>:
{
    2188:	7179                	addi	sp,sp,-48
    218a:	f406                	sd	ra,40(sp)
    218c:	f022                	sd	s0,32(sp)
    218e:	ec26                	sd	s1,24(sp)
    2190:	1800                	addi	s0,sp,48
    2192:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    2194:	00005517          	auipc	a0,0x5
    2198:	91450513          	addi	a0,a0,-1772 # 6aa8 <malloc+0xf92>
    219c:	00003097          	auipc	ra,0x3
    21a0:	594080e7          	jalr	1428(ra) # 5730 <unlink>
  pid = fork();
    21a4:	00003097          	auipc	ra,0x3
    21a8:	534080e7          	jalr	1332(ra) # 56d8 <fork>
  if(pid == 0){
    21ac:	c121                	beqz	a0,21ec <bigargtest+0x64>
  } else if(pid < 0){
    21ae:	0a054063          	bltz	a0,224e <bigargtest+0xc6>
  wait(&xstatus);
    21b2:	fdc40513          	addi	a0,s0,-36
    21b6:	00003097          	auipc	ra,0x3
    21ba:	532080e7          	jalr	1330(ra) # 56e8 <wait>
  if(xstatus != 0)
    21be:	fdc42503          	lw	a0,-36(s0)
    21c2:	e545                	bnez	a0,226a <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    21c4:	4581                	li	a1,0
    21c6:	00005517          	auipc	a0,0x5
    21ca:	8e250513          	addi	a0,a0,-1822 # 6aa8 <malloc+0xf92>
    21ce:	00003097          	auipc	ra,0x3
    21d2:	552080e7          	jalr	1362(ra) # 5720 <open>
  if(fd < 0){
    21d6:	08054e63          	bltz	a0,2272 <bigargtest+0xea>
  close(fd);
    21da:	00003097          	auipc	ra,0x3
    21de:	52e080e7          	jalr	1326(ra) # 5708 <close>
}
    21e2:	70a2                	ld	ra,40(sp)
    21e4:	7402                	ld	s0,32(sp)
    21e6:	64e2                	ld	s1,24(sp)
    21e8:	6145                	addi	sp,sp,48
    21ea:	8082                	ret
    21ec:	00006797          	auipc	a5,0x6
    21f0:	1cc78793          	addi	a5,a5,460 # 83b8 <args.1>
    21f4:	00006697          	auipc	a3,0x6
    21f8:	2bc68693          	addi	a3,a3,700 # 84b0 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    21fc:	00005717          	auipc	a4,0x5
    2200:	8bc70713          	addi	a4,a4,-1860 # 6ab8 <malloc+0xfa2>
    2204:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    2206:	07a1                	addi	a5,a5,8
    2208:	fed79ee3          	bne	a5,a3,2204 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    220c:	00006597          	auipc	a1,0x6
    2210:	1ac58593          	addi	a1,a1,428 # 83b8 <args.1>
    2214:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    2218:	00004517          	auipc	a0,0x4
    221c:	d5050513          	addi	a0,a0,-688 # 5f68 <malloc+0x452>
    2220:	00003097          	auipc	ra,0x3
    2224:	4f8080e7          	jalr	1272(ra) # 5718 <exec>
    fd = open("bigarg-ok", O_CREATE);
    2228:	20000593          	li	a1,512
    222c:	00005517          	auipc	a0,0x5
    2230:	87c50513          	addi	a0,a0,-1924 # 6aa8 <malloc+0xf92>
    2234:	00003097          	auipc	ra,0x3
    2238:	4ec080e7          	jalr	1260(ra) # 5720 <open>
    close(fd);
    223c:	00003097          	auipc	ra,0x3
    2240:	4cc080e7          	jalr	1228(ra) # 5708 <close>
    exit(0);
    2244:	4501                	li	a0,0
    2246:	00003097          	auipc	ra,0x3
    224a:	49a080e7          	jalr	1178(ra) # 56e0 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    224e:	85a6                	mv	a1,s1
    2250:	00005517          	auipc	a0,0x5
    2254:	94850513          	addi	a0,a0,-1720 # 6b98 <malloc+0x1082>
    2258:	00004097          	auipc	ra,0x4
    225c:	800080e7          	jalr	-2048(ra) # 5a58 <printf>
    exit(1);
    2260:	4505                	li	a0,1
    2262:	00003097          	auipc	ra,0x3
    2266:	47e080e7          	jalr	1150(ra) # 56e0 <exit>
    exit(xstatus);
    226a:	00003097          	auipc	ra,0x3
    226e:	476080e7          	jalr	1142(ra) # 56e0 <exit>
    printf("%s: bigarg test failed!\n", s);
    2272:	85a6                	mv	a1,s1
    2274:	00005517          	auipc	a0,0x5
    2278:	94450513          	addi	a0,a0,-1724 # 6bb8 <malloc+0x10a2>
    227c:	00003097          	auipc	ra,0x3
    2280:	7dc080e7          	jalr	2012(ra) # 5a58 <printf>
    exit(1);
    2284:	4505                	li	a0,1
    2286:	00003097          	auipc	ra,0x3
    228a:	45a080e7          	jalr	1114(ra) # 56e0 <exit>

000000000000228e <stacktest>:
{
    228e:	7179                	addi	sp,sp,-48
    2290:	f406                	sd	ra,40(sp)
    2292:	f022                	sd	s0,32(sp)
    2294:	ec26                	sd	s1,24(sp)
    2296:	1800                	addi	s0,sp,48
    2298:	84aa                	mv	s1,a0
  pid = fork();
    229a:	00003097          	auipc	ra,0x3
    229e:	43e080e7          	jalr	1086(ra) # 56d8 <fork>
  if(pid == 0) {
    22a2:	c115                	beqz	a0,22c6 <stacktest+0x38>
  } else if(pid < 0){
    22a4:	04054463          	bltz	a0,22ec <stacktest+0x5e>
  wait(&xstatus);
    22a8:	fdc40513          	addi	a0,s0,-36
    22ac:	00003097          	auipc	ra,0x3
    22b0:	43c080e7          	jalr	1084(ra) # 56e8 <wait>
  if(xstatus == -1)  // kernel killed child?
    22b4:	fdc42503          	lw	a0,-36(s0)
    22b8:	57fd                	li	a5,-1
    22ba:	04f50763          	beq	a0,a5,2308 <stacktest+0x7a>
    exit(xstatus);
    22be:	00003097          	auipc	ra,0x3
    22c2:	422080e7          	jalr	1058(ra) # 56e0 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    22c6:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    22c8:	77fd                	lui	a5,0xfffff
    22ca:	97ba                	add	a5,a5,a4
    22cc:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff0420>
    22d0:	85a6                	mv	a1,s1
    22d2:	00005517          	auipc	a0,0x5
    22d6:	90650513          	addi	a0,a0,-1786 # 6bd8 <malloc+0x10c2>
    22da:	00003097          	auipc	ra,0x3
    22de:	77e080e7          	jalr	1918(ra) # 5a58 <printf>
    exit(1);
    22e2:	4505                	li	a0,1
    22e4:	00003097          	auipc	ra,0x3
    22e8:	3fc080e7          	jalr	1020(ra) # 56e0 <exit>
    printf("%s: fork failed\n", s);
    22ec:	85a6                	mv	a1,s1
    22ee:	00004517          	auipc	a0,0x4
    22f2:	4b250513          	addi	a0,a0,1202 # 67a0 <malloc+0xc8a>
    22f6:	00003097          	auipc	ra,0x3
    22fa:	762080e7          	jalr	1890(ra) # 5a58 <printf>
    exit(1);
    22fe:	4505                	li	a0,1
    2300:	00003097          	auipc	ra,0x3
    2304:	3e0080e7          	jalr	992(ra) # 56e0 <exit>
    exit(0);
    2308:	4501                	li	a0,0
    230a:	00003097          	auipc	ra,0x3
    230e:	3d6080e7          	jalr	982(ra) # 56e0 <exit>

0000000000002312 <copyinstr3>:
{
    2312:	7179                	addi	sp,sp,-48
    2314:	f406                	sd	ra,40(sp)
    2316:	f022                	sd	s0,32(sp)
    2318:	ec26                	sd	s1,24(sp)
    231a:	1800                	addi	s0,sp,48
  sbrk(8192);
    231c:	6509                	lui	a0,0x2
    231e:	00003097          	auipc	ra,0x3
    2322:	44a080e7          	jalr	1098(ra) # 5768 <sbrk>
  uint64 top = (uint64) sbrk(0);
    2326:	4501                	li	a0,0
    2328:	00003097          	auipc	ra,0x3
    232c:	440080e7          	jalr	1088(ra) # 5768 <sbrk>
  if((top % PGSIZE) != 0){
    2330:	03451793          	slli	a5,a0,0x34
    2334:	e3c9                	bnez	a5,23b6 <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    2336:	4501                	li	a0,0
    2338:	00003097          	auipc	ra,0x3
    233c:	430080e7          	jalr	1072(ra) # 5768 <sbrk>
  if(top % PGSIZE){
    2340:	03451793          	slli	a5,a0,0x34
    2344:	e3d9                	bnez	a5,23ca <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    2346:	fff50493          	addi	s1,a0,-1 # 1fff <forktest+0x3>
  *b = 'x';
    234a:	07800793          	li	a5,120
    234e:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    2352:	8526                	mv	a0,s1
    2354:	00003097          	auipc	ra,0x3
    2358:	3dc080e7          	jalr	988(ra) # 5730 <unlink>
  if(ret != -1){
    235c:	57fd                	li	a5,-1
    235e:	08f51363          	bne	a0,a5,23e4 <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    2362:	20100593          	li	a1,513
    2366:	8526                	mv	a0,s1
    2368:	00003097          	auipc	ra,0x3
    236c:	3b8080e7          	jalr	952(ra) # 5720 <open>
  if(fd != -1){
    2370:	57fd                	li	a5,-1
    2372:	08f51863          	bne	a0,a5,2402 <copyinstr3+0xf0>
  ret = link(b, b);
    2376:	85a6                	mv	a1,s1
    2378:	8526                	mv	a0,s1
    237a:	00003097          	auipc	ra,0x3
    237e:	3c6080e7          	jalr	966(ra) # 5740 <link>
  if(ret != -1){
    2382:	57fd                	li	a5,-1
    2384:	08f51e63          	bne	a0,a5,2420 <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    2388:	00005797          	auipc	a5,0x5
    238c:	4e878793          	addi	a5,a5,1256 # 7870 <malloc+0x1d5a>
    2390:	fcf43823          	sd	a5,-48(s0)
    2394:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    2398:	fd040593          	addi	a1,s0,-48
    239c:	8526                	mv	a0,s1
    239e:	00003097          	auipc	ra,0x3
    23a2:	37a080e7          	jalr	890(ra) # 5718 <exec>
  if(ret != -1){
    23a6:	57fd                	li	a5,-1
    23a8:	08f51c63          	bne	a0,a5,2440 <copyinstr3+0x12e>
}
    23ac:	70a2                	ld	ra,40(sp)
    23ae:	7402                	ld	s0,32(sp)
    23b0:	64e2                	ld	s1,24(sp)
    23b2:	6145                	addi	sp,sp,48
    23b4:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    23b6:	0347d513          	srli	a0,a5,0x34
    23ba:	6785                	lui	a5,0x1
    23bc:	40a7853b          	subw	a0,a5,a0
    23c0:	00003097          	auipc	ra,0x3
    23c4:	3a8080e7          	jalr	936(ra) # 5768 <sbrk>
    23c8:	b7bd                	j	2336 <copyinstr3+0x24>
    printf("oops\n");
    23ca:	00005517          	auipc	a0,0x5
    23ce:	83650513          	addi	a0,a0,-1994 # 6c00 <malloc+0x10ea>
    23d2:	00003097          	auipc	ra,0x3
    23d6:	686080e7          	jalr	1670(ra) # 5a58 <printf>
    exit(1);
    23da:	4505                	li	a0,1
    23dc:	00003097          	auipc	ra,0x3
    23e0:	304080e7          	jalr	772(ra) # 56e0 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    23e4:	862a                	mv	a2,a0
    23e6:	85a6                	mv	a1,s1
    23e8:	00004517          	auipc	a0,0x4
    23ec:	2d850513          	addi	a0,a0,728 # 66c0 <malloc+0xbaa>
    23f0:	00003097          	auipc	ra,0x3
    23f4:	668080e7          	jalr	1640(ra) # 5a58 <printf>
    exit(1);
    23f8:	4505                	li	a0,1
    23fa:	00003097          	auipc	ra,0x3
    23fe:	2e6080e7          	jalr	742(ra) # 56e0 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    2402:	862a                	mv	a2,a0
    2404:	85a6                	mv	a1,s1
    2406:	00004517          	auipc	a0,0x4
    240a:	2da50513          	addi	a0,a0,730 # 66e0 <malloc+0xbca>
    240e:	00003097          	auipc	ra,0x3
    2412:	64a080e7          	jalr	1610(ra) # 5a58 <printf>
    exit(1);
    2416:	4505                	li	a0,1
    2418:	00003097          	auipc	ra,0x3
    241c:	2c8080e7          	jalr	712(ra) # 56e0 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    2420:	86aa                	mv	a3,a0
    2422:	8626                	mv	a2,s1
    2424:	85a6                	mv	a1,s1
    2426:	00004517          	auipc	a0,0x4
    242a:	2da50513          	addi	a0,a0,730 # 6700 <malloc+0xbea>
    242e:	00003097          	auipc	ra,0x3
    2432:	62a080e7          	jalr	1578(ra) # 5a58 <printf>
    exit(1);
    2436:	4505                	li	a0,1
    2438:	00003097          	auipc	ra,0x3
    243c:	2a8080e7          	jalr	680(ra) # 56e0 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    2440:	567d                	li	a2,-1
    2442:	85a6                	mv	a1,s1
    2444:	00004517          	auipc	a0,0x4
    2448:	2e450513          	addi	a0,a0,740 # 6728 <malloc+0xc12>
    244c:	00003097          	auipc	ra,0x3
    2450:	60c080e7          	jalr	1548(ra) # 5a58 <printf>
    exit(1);
    2454:	4505                	li	a0,1
    2456:	00003097          	auipc	ra,0x3
    245a:	28a080e7          	jalr	650(ra) # 56e0 <exit>

000000000000245e <rwsbrk>:
{
    245e:	1101                	addi	sp,sp,-32
    2460:	ec06                	sd	ra,24(sp)
    2462:	e822                	sd	s0,16(sp)
    2464:	e426                	sd	s1,8(sp)
    2466:	e04a                	sd	s2,0(sp)
    2468:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    246a:	6509                	lui	a0,0x2
    246c:	00003097          	auipc	ra,0x3
    2470:	2fc080e7          	jalr	764(ra) # 5768 <sbrk>
  if(a == 0xffffffffffffffffLL) {
    2474:	57fd                	li	a5,-1
    2476:	06f50363          	beq	a0,a5,24dc <rwsbrk+0x7e>
    247a:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    247c:	7579                	lui	a0,0xffffe
    247e:	00003097          	auipc	ra,0x3
    2482:	2ea080e7          	jalr	746(ra) # 5768 <sbrk>
    2486:	57fd                	li	a5,-1
    2488:	06f50763          	beq	a0,a5,24f6 <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    248c:	20100593          	li	a1,513
    2490:	00003517          	auipc	a0,0x3
    2494:	7e850513          	addi	a0,a0,2024 # 5c78 <malloc+0x162>
    2498:	00003097          	auipc	ra,0x3
    249c:	288080e7          	jalr	648(ra) # 5720 <open>
    24a0:	892a                	mv	s2,a0
  if(fd < 0){
    24a2:	06054763          	bltz	a0,2510 <rwsbrk+0xb2>
  n = write(fd, (void*)(a+4096), 1024);
    24a6:	6505                	lui	a0,0x1
    24a8:	94aa                	add	s1,s1,a0
    24aa:	40000613          	li	a2,1024
    24ae:	85a6                	mv	a1,s1
    24b0:	854a                	mv	a0,s2
    24b2:	00003097          	auipc	ra,0x3
    24b6:	24e080e7          	jalr	590(ra) # 5700 <write>
    24ba:	862a                	mv	a2,a0
  if(n >= 0){
    24bc:	06054763          	bltz	a0,252a <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    24c0:	85a6                	mv	a1,s1
    24c2:	00004517          	auipc	a0,0x4
    24c6:	79650513          	addi	a0,a0,1942 # 6c58 <malloc+0x1142>
    24ca:	00003097          	auipc	ra,0x3
    24ce:	58e080e7          	jalr	1422(ra) # 5a58 <printf>
    exit(1);
    24d2:	4505                	li	a0,1
    24d4:	00003097          	auipc	ra,0x3
    24d8:	20c080e7          	jalr	524(ra) # 56e0 <exit>
    printf("sbrk(rwsbrk) failed\n");
    24dc:	00004517          	auipc	a0,0x4
    24e0:	72c50513          	addi	a0,a0,1836 # 6c08 <malloc+0x10f2>
    24e4:	00003097          	auipc	ra,0x3
    24e8:	574080e7          	jalr	1396(ra) # 5a58 <printf>
    exit(1);
    24ec:	4505                	li	a0,1
    24ee:	00003097          	auipc	ra,0x3
    24f2:	1f2080e7          	jalr	498(ra) # 56e0 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    24f6:	00004517          	auipc	a0,0x4
    24fa:	72a50513          	addi	a0,a0,1834 # 6c20 <malloc+0x110a>
    24fe:	00003097          	auipc	ra,0x3
    2502:	55a080e7          	jalr	1370(ra) # 5a58 <printf>
    exit(1);
    2506:	4505                	li	a0,1
    2508:	00003097          	auipc	ra,0x3
    250c:	1d8080e7          	jalr	472(ra) # 56e0 <exit>
    printf("open(rwsbrk) failed\n");
    2510:	00004517          	auipc	a0,0x4
    2514:	73050513          	addi	a0,a0,1840 # 6c40 <malloc+0x112a>
    2518:	00003097          	auipc	ra,0x3
    251c:	540080e7          	jalr	1344(ra) # 5a58 <printf>
    exit(1);
    2520:	4505                	li	a0,1
    2522:	00003097          	auipc	ra,0x3
    2526:	1be080e7          	jalr	446(ra) # 56e0 <exit>
  close(fd);
    252a:	854a                	mv	a0,s2
    252c:	00003097          	auipc	ra,0x3
    2530:	1dc080e7          	jalr	476(ra) # 5708 <close>
  unlink("rwsbrk");
    2534:	00003517          	auipc	a0,0x3
    2538:	74450513          	addi	a0,a0,1860 # 5c78 <malloc+0x162>
    253c:	00003097          	auipc	ra,0x3
    2540:	1f4080e7          	jalr	500(ra) # 5730 <unlink>
  fd = open("README", O_RDONLY);
    2544:	4581                	li	a1,0
    2546:	00004517          	auipc	a0,0x4
    254a:	bba50513          	addi	a0,a0,-1094 # 6100 <malloc+0x5ea>
    254e:	00003097          	auipc	ra,0x3
    2552:	1d2080e7          	jalr	466(ra) # 5720 <open>
    2556:	892a                	mv	s2,a0
  if(fd < 0){
    2558:	02054963          	bltz	a0,258a <rwsbrk+0x12c>
  n = read(fd, (void*)(a+4096), 10);
    255c:	4629                	li	a2,10
    255e:	85a6                	mv	a1,s1
    2560:	00003097          	auipc	ra,0x3
    2564:	198080e7          	jalr	408(ra) # 56f8 <read>
    2568:	862a                	mv	a2,a0
  if(n >= 0){
    256a:	02054d63          	bltz	a0,25a4 <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    256e:	85a6                	mv	a1,s1
    2570:	00004517          	auipc	a0,0x4
    2574:	71850513          	addi	a0,a0,1816 # 6c88 <malloc+0x1172>
    2578:	00003097          	auipc	ra,0x3
    257c:	4e0080e7          	jalr	1248(ra) # 5a58 <printf>
    exit(1);
    2580:	4505                	li	a0,1
    2582:	00003097          	auipc	ra,0x3
    2586:	15e080e7          	jalr	350(ra) # 56e0 <exit>
    printf("open(rwsbrk) failed\n");
    258a:	00004517          	auipc	a0,0x4
    258e:	6b650513          	addi	a0,a0,1718 # 6c40 <malloc+0x112a>
    2592:	00003097          	auipc	ra,0x3
    2596:	4c6080e7          	jalr	1222(ra) # 5a58 <printf>
    exit(1);
    259a:	4505                	li	a0,1
    259c:	00003097          	auipc	ra,0x3
    25a0:	144080e7          	jalr	324(ra) # 56e0 <exit>
  close(fd);
    25a4:	854a                	mv	a0,s2
    25a6:	00003097          	auipc	ra,0x3
    25aa:	162080e7          	jalr	354(ra) # 5708 <close>
  exit(0);
    25ae:	4501                	li	a0,0
    25b0:	00003097          	auipc	ra,0x3
    25b4:	130080e7          	jalr	304(ra) # 56e0 <exit>

00000000000025b8 <sbrkbasic>:
{
    25b8:	7139                	addi	sp,sp,-64
    25ba:	fc06                	sd	ra,56(sp)
    25bc:	f822                	sd	s0,48(sp)
    25be:	f426                	sd	s1,40(sp)
    25c0:	f04a                	sd	s2,32(sp)
    25c2:	ec4e                	sd	s3,24(sp)
    25c4:	e852                	sd	s4,16(sp)
    25c6:	0080                	addi	s0,sp,64
    25c8:	8a2a                	mv	s4,a0
  pid = fork();
    25ca:	00003097          	auipc	ra,0x3
    25ce:	10e080e7          	jalr	270(ra) # 56d8 <fork>
  if(pid < 0){
    25d2:	02054c63          	bltz	a0,260a <sbrkbasic+0x52>
  if(pid == 0){
    25d6:	ed21                	bnez	a0,262e <sbrkbasic+0x76>
    a = sbrk(TOOMUCH);
    25d8:	40000537          	lui	a0,0x40000
    25dc:	00003097          	auipc	ra,0x3
    25e0:	18c080e7          	jalr	396(ra) # 5768 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    25e4:	57fd                	li	a5,-1
    25e6:	02f50f63          	beq	a0,a5,2624 <sbrkbasic+0x6c>
    for(b = a; b < a+TOOMUCH; b += 4096){
    25ea:	400007b7          	lui	a5,0x40000
    25ee:	97aa                	add	a5,a5,a0
      *b = 99;
    25f0:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    25f4:	6705                	lui	a4,0x1
      *b = 99;
    25f6:	00d50023          	sb	a3,0(a0) # 40000000 <__BSS_END__+0x3fff1420>
    for(b = a; b < a+TOOMUCH; b += 4096){
    25fa:	953a                	add	a0,a0,a4
    25fc:	fef51de3          	bne	a0,a5,25f6 <sbrkbasic+0x3e>
    exit(1);
    2600:	4505                	li	a0,1
    2602:	00003097          	auipc	ra,0x3
    2606:	0de080e7          	jalr	222(ra) # 56e0 <exit>
    printf("fork failed in sbrkbasic\n");
    260a:	00004517          	auipc	a0,0x4
    260e:	6a650513          	addi	a0,a0,1702 # 6cb0 <malloc+0x119a>
    2612:	00003097          	auipc	ra,0x3
    2616:	446080e7          	jalr	1094(ra) # 5a58 <printf>
    exit(1);
    261a:	4505                	li	a0,1
    261c:	00003097          	auipc	ra,0x3
    2620:	0c4080e7          	jalr	196(ra) # 56e0 <exit>
      exit(0);
    2624:	4501                	li	a0,0
    2626:	00003097          	auipc	ra,0x3
    262a:	0ba080e7          	jalr	186(ra) # 56e0 <exit>
  wait(&xstatus);
    262e:	fcc40513          	addi	a0,s0,-52
    2632:	00003097          	auipc	ra,0x3
    2636:	0b6080e7          	jalr	182(ra) # 56e8 <wait>
  if(xstatus == 1){
    263a:	fcc42703          	lw	a4,-52(s0)
    263e:	4785                	li	a5,1
    2640:	00f70d63          	beq	a4,a5,265a <sbrkbasic+0xa2>
  a = sbrk(0);
    2644:	4501                	li	a0,0
    2646:	00003097          	auipc	ra,0x3
    264a:	122080e7          	jalr	290(ra) # 5768 <sbrk>
    264e:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    2650:	4901                	li	s2,0
    2652:	6985                	lui	s3,0x1
    2654:	38898993          	addi	s3,s3,904 # 1388 <copyinstr2+0x1d6>
    2658:	a005                	j	2678 <sbrkbasic+0xc0>
    printf("%s: too much memory allocated!\n", s);
    265a:	85d2                	mv	a1,s4
    265c:	00004517          	auipc	a0,0x4
    2660:	67450513          	addi	a0,a0,1652 # 6cd0 <malloc+0x11ba>
    2664:	00003097          	auipc	ra,0x3
    2668:	3f4080e7          	jalr	1012(ra) # 5a58 <printf>
    exit(1);
    266c:	4505                	li	a0,1
    266e:	00003097          	auipc	ra,0x3
    2672:	072080e7          	jalr	114(ra) # 56e0 <exit>
    a = b + 1;
    2676:	84be                	mv	s1,a5
    b = sbrk(1);
    2678:	4505                	li	a0,1
    267a:	00003097          	auipc	ra,0x3
    267e:	0ee080e7          	jalr	238(ra) # 5768 <sbrk>
    if(b != a){
    2682:	04951c63          	bne	a0,s1,26da <sbrkbasic+0x122>
    *b = 1;
    2686:	4785                	li	a5,1
    2688:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    268c:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    2690:	2905                	addiw	s2,s2,1
    2692:	ff3912e3          	bne	s2,s3,2676 <sbrkbasic+0xbe>
  pid = fork();
    2696:	00003097          	auipc	ra,0x3
    269a:	042080e7          	jalr	66(ra) # 56d8 <fork>
    269e:	892a                	mv	s2,a0
  if(pid < 0){
    26a0:	04054d63          	bltz	a0,26fa <sbrkbasic+0x142>
  c = sbrk(1);
    26a4:	4505                	li	a0,1
    26a6:	00003097          	auipc	ra,0x3
    26aa:	0c2080e7          	jalr	194(ra) # 5768 <sbrk>
  c = sbrk(1);
    26ae:	4505                	li	a0,1
    26b0:	00003097          	auipc	ra,0x3
    26b4:	0b8080e7          	jalr	184(ra) # 5768 <sbrk>
  if(c != a + 1){
    26b8:	0489                	addi	s1,s1,2
    26ba:	04a48e63          	beq	s1,a0,2716 <sbrkbasic+0x15e>
    printf("%s: sbrk test failed post-fork\n", s);
    26be:	85d2                	mv	a1,s4
    26c0:	00004517          	auipc	a0,0x4
    26c4:	67050513          	addi	a0,a0,1648 # 6d30 <malloc+0x121a>
    26c8:	00003097          	auipc	ra,0x3
    26cc:	390080e7          	jalr	912(ra) # 5a58 <printf>
    exit(1);
    26d0:	4505                	li	a0,1
    26d2:	00003097          	auipc	ra,0x3
    26d6:	00e080e7          	jalr	14(ra) # 56e0 <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    26da:	86aa                	mv	a3,a0
    26dc:	8626                	mv	a2,s1
    26de:	85ca                	mv	a1,s2
    26e0:	00004517          	auipc	a0,0x4
    26e4:	61050513          	addi	a0,a0,1552 # 6cf0 <malloc+0x11da>
    26e8:	00003097          	auipc	ra,0x3
    26ec:	370080e7          	jalr	880(ra) # 5a58 <printf>
      exit(1);
    26f0:	4505                	li	a0,1
    26f2:	00003097          	auipc	ra,0x3
    26f6:	fee080e7          	jalr	-18(ra) # 56e0 <exit>
    printf("%s: sbrk test fork failed\n", s);
    26fa:	85d2                	mv	a1,s4
    26fc:	00004517          	auipc	a0,0x4
    2700:	61450513          	addi	a0,a0,1556 # 6d10 <malloc+0x11fa>
    2704:	00003097          	auipc	ra,0x3
    2708:	354080e7          	jalr	852(ra) # 5a58 <printf>
    exit(1);
    270c:	4505                	li	a0,1
    270e:	00003097          	auipc	ra,0x3
    2712:	fd2080e7          	jalr	-46(ra) # 56e0 <exit>
  if(pid == 0)
    2716:	00091763          	bnez	s2,2724 <sbrkbasic+0x16c>
    exit(0);
    271a:	4501                	li	a0,0
    271c:	00003097          	auipc	ra,0x3
    2720:	fc4080e7          	jalr	-60(ra) # 56e0 <exit>
  wait(&xstatus);
    2724:	fcc40513          	addi	a0,s0,-52
    2728:	00003097          	auipc	ra,0x3
    272c:	fc0080e7          	jalr	-64(ra) # 56e8 <wait>
  exit(xstatus);
    2730:	fcc42503          	lw	a0,-52(s0)
    2734:	00003097          	auipc	ra,0x3
    2738:	fac080e7          	jalr	-84(ra) # 56e0 <exit>

000000000000273c <sbrkmuch>:
{
    273c:	7179                	addi	sp,sp,-48
    273e:	f406                	sd	ra,40(sp)
    2740:	f022                	sd	s0,32(sp)
    2742:	ec26                	sd	s1,24(sp)
    2744:	e84a                	sd	s2,16(sp)
    2746:	e44e                	sd	s3,8(sp)
    2748:	e052                	sd	s4,0(sp)
    274a:	1800                	addi	s0,sp,48
    274c:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    274e:	4501                	li	a0,0
    2750:	00003097          	auipc	ra,0x3
    2754:	018080e7          	jalr	24(ra) # 5768 <sbrk>
    2758:	892a                	mv	s2,a0
  a = sbrk(0);
    275a:	4501                	li	a0,0
    275c:	00003097          	auipc	ra,0x3
    2760:	00c080e7          	jalr	12(ra) # 5768 <sbrk>
    2764:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2766:	06400537          	lui	a0,0x6400
    276a:	9d05                	subw	a0,a0,s1
    276c:	00003097          	auipc	ra,0x3
    2770:	ffc080e7          	jalr	-4(ra) # 5768 <sbrk>
  if (p != a) {
    2774:	0ca49863          	bne	s1,a0,2844 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    2778:	4501                	li	a0,0
    277a:	00003097          	auipc	ra,0x3
    277e:	fee080e7          	jalr	-18(ra) # 5768 <sbrk>
    2782:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    2784:	00a4f963          	bgeu	s1,a0,2796 <sbrkmuch+0x5a>
    *pp = 1;
    2788:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    278a:	6705                	lui	a4,0x1
    *pp = 1;
    278c:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    2790:	94ba                	add	s1,s1,a4
    2792:	fef4ede3          	bltu	s1,a5,278c <sbrkmuch+0x50>
  *lastaddr = 99;
    2796:	064007b7          	lui	a5,0x6400
    279a:	06300713          	li	a4,99
    279e:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f141f>
  a = sbrk(0);
    27a2:	4501                	li	a0,0
    27a4:	00003097          	auipc	ra,0x3
    27a8:	fc4080e7          	jalr	-60(ra) # 5768 <sbrk>
    27ac:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    27ae:	757d                	lui	a0,0xfffff
    27b0:	00003097          	auipc	ra,0x3
    27b4:	fb8080e7          	jalr	-72(ra) # 5768 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    27b8:	57fd                	li	a5,-1
    27ba:	0af50363          	beq	a0,a5,2860 <sbrkmuch+0x124>
  c = sbrk(0);
    27be:	4501                	li	a0,0
    27c0:	00003097          	auipc	ra,0x3
    27c4:	fa8080e7          	jalr	-88(ra) # 5768 <sbrk>
  if(c != a - PGSIZE){
    27c8:	77fd                	lui	a5,0xfffff
    27ca:	97a6                	add	a5,a5,s1
    27cc:	0af51863          	bne	a0,a5,287c <sbrkmuch+0x140>
  a = sbrk(0);
    27d0:	4501                	li	a0,0
    27d2:	00003097          	auipc	ra,0x3
    27d6:	f96080e7          	jalr	-106(ra) # 5768 <sbrk>
    27da:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    27dc:	6505                	lui	a0,0x1
    27de:	00003097          	auipc	ra,0x3
    27e2:	f8a080e7          	jalr	-118(ra) # 5768 <sbrk>
    27e6:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    27e8:	0aa49a63          	bne	s1,a0,289c <sbrkmuch+0x160>
    27ec:	4501                	li	a0,0
    27ee:	00003097          	auipc	ra,0x3
    27f2:	f7a080e7          	jalr	-134(ra) # 5768 <sbrk>
    27f6:	6785                	lui	a5,0x1
    27f8:	97a6                	add	a5,a5,s1
    27fa:	0af51163          	bne	a0,a5,289c <sbrkmuch+0x160>
  if(*lastaddr == 99){
    27fe:	064007b7          	lui	a5,0x6400
    2802:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f141f>
    2806:	06300793          	li	a5,99
    280a:	0af70963          	beq	a4,a5,28bc <sbrkmuch+0x180>
  a = sbrk(0);
    280e:	4501                	li	a0,0
    2810:	00003097          	auipc	ra,0x3
    2814:	f58080e7          	jalr	-168(ra) # 5768 <sbrk>
    2818:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    281a:	4501                	li	a0,0
    281c:	00003097          	auipc	ra,0x3
    2820:	f4c080e7          	jalr	-180(ra) # 5768 <sbrk>
    2824:	40a9053b          	subw	a0,s2,a0
    2828:	00003097          	auipc	ra,0x3
    282c:	f40080e7          	jalr	-192(ra) # 5768 <sbrk>
  if(c != a){
    2830:	0aa49463          	bne	s1,a0,28d8 <sbrkmuch+0x19c>
}
    2834:	70a2                	ld	ra,40(sp)
    2836:	7402                	ld	s0,32(sp)
    2838:	64e2                	ld	s1,24(sp)
    283a:	6942                	ld	s2,16(sp)
    283c:	69a2                	ld	s3,8(sp)
    283e:	6a02                	ld	s4,0(sp)
    2840:	6145                	addi	sp,sp,48
    2842:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2844:	85ce                	mv	a1,s3
    2846:	00004517          	auipc	a0,0x4
    284a:	50a50513          	addi	a0,a0,1290 # 6d50 <malloc+0x123a>
    284e:	00003097          	auipc	ra,0x3
    2852:	20a080e7          	jalr	522(ra) # 5a58 <printf>
    exit(1);
    2856:	4505                	li	a0,1
    2858:	00003097          	auipc	ra,0x3
    285c:	e88080e7          	jalr	-376(ra) # 56e0 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2860:	85ce                	mv	a1,s3
    2862:	00004517          	auipc	a0,0x4
    2866:	53650513          	addi	a0,a0,1334 # 6d98 <malloc+0x1282>
    286a:	00003097          	auipc	ra,0x3
    286e:	1ee080e7          	jalr	494(ra) # 5a58 <printf>
    exit(1);
    2872:	4505                	li	a0,1
    2874:	00003097          	auipc	ra,0x3
    2878:	e6c080e7          	jalr	-404(ra) # 56e0 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    287c:	86aa                	mv	a3,a0
    287e:	8626                	mv	a2,s1
    2880:	85ce                	mv	a1,s3
    2882:	00004517          	auipc	a0,0x4
    2886:	53650513          	addi	a0,a0,1334 # 6db8 <malloc+0x12a2>
    288a:	00003097          	auipc	ra,0x3
    288e:	1ce080e7          	jalr	462(ra) # 5a58 <printf>
    exit(1);
    2892:	4505                	li	a0,1
    2894:	00003097          	auipc	ra,0x3
    2898:	e4c080e7          	jalr	-436(ra) # 56e0 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    289c:	86d2                	mv	a3,s4
    289e:	8626                	mv	a2,s1
    28a0:	85ce                	mv	a1,s3
    28a2:	00004517          	auipc	a0,0x4
    28a6:	55650513          	addi	a0,a0,1366 # 6df8 <malloc+0x12e2>
    28aa:	00003097          	auipc	ra,0x3
    28ae:	1ae080e7          	jalr	430(ra) # 5a58 <printf>
    exit(1);
    28b2:	4505                	li	a0,1
    28b4:	00003097          	auipc	ra,0x3
    28b8:	e2c080e7          	jalr	-468(ra) # 56e0 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    28bc:	85ce                	mv	a1,s3
    28be:	00004517          	auipc	a0,0x4
    28c2:	56a50513          	addi	a0,a0,1386 # 6e28 <malloc+0x1312>
    28c6:	00003097          	auipc	ra,0x3
    28ca:	192080e7          	jalr	402(ra) # 5a58 <printf>
    exit(1);
    28ce:	4505                	li	a0,1
    28d0:	00003097          	auipc	ra,0x3
    28d4:	e10080e7          	jalr	-496(ra) # 56e0 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    28d8:	86aa                	mv	a3,a0
    28da:	8626                	mv	a2,s1
    28dc:	85ce                	mv	a1,s3
    28de:	00004517          	auipc	a0,0x4
    28e2:	58250513          	addi	a0,a0,1410 # 6e60 <malloc+0x134a>
    28e6:	00003097          	auipc	ra,0x3
    28ea:	172080e7          	jalr	370(ra) # 5a58 <printf>
    exit(1);
    28ee:	4505                	li	a0,1
    28f0:	00003097          	auipc	ra,0x3
    28f4:	df0080e7          	jalr	-528(ra) # 56e0 <exit>

00000000000028f8 <sbrkarg>:
{
    28f8:	7179                	addi	sp,sp,-48
    28fa:	f406                	sd	ra,40(sp)
    28fc:	f022                	sd	s0,32(sp)
    28fe:	ec26                	sd	s1,24(sp)
    2900:	e84a                	sd	s2,16(sp)
    2902:	e44e                	sd	s3,8(sp)
    2904:	1800                	addi	s0,sp,48
    2906:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2908:	6505                	lui	a0,0x1
    290a:	00003097          	auipc	ra,0x3
    290e:	e5e080e7          	jalr	-418(ra) # 5768 <sbrk>
    2912:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    2914:	20100593          	li	a1,513
    2918:	00004517          	auipc	a0,0x4
    291c:	57050513          	addi	a0,a0,1392 # 6e88 <malloc+0x1372>
    2920:	00003097          	auipc	ra,0x3
    2924:	e00080e7          	jalr	-512(ra) # 5720 <open>
    2928:	84aa                	mv	s1,a0
  unlink("sbrk");
    292a:	00004517          	auipc	a0,0x4
    292e:	55e50513          	addi	a0,a0,1374 # 6e88 <malloc+0x1372>
    2932:	00003097          	auipc	ra,0x3
    2936:	dfe080e7          	jalr	-514(ra) # 5730 <unlink>
  if(fd < 0)  {
    293a:	0404c163          	bltz	s1,297c <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    293e:	6605                	lui	a2,0x1
    2940:	85ca                	mv	a1,s2
    2942:	8526                	mv	a0,s1
    2944:	00003097          	auipc	ra,0x3
    2948:	dbc080e7          	jalr	-580(ra) # 5700 <write>
    294c:	04054663          	bltz	a0,2998 <sbrkarg+0xa0>
  close(fd);
    2950:	8526                	mv	a0,s1
    2952:	00003097          	auipc	ra,0x3
    2956:	db6080e7          	jalr	-586(ra) # 5708 <close>
  a = sbrk(PGSIZE);
    295a:	6505                	lui	a0,0x1
    295c:	00003097          	auipc	ra,0x3
    2960:	e0c080e7          	jalr	-500(ra) # 5768 <sbrk>
  if(pipe((int *) a) != 0){
    2964:	00003097          	auipc	ra,0x3
    2968:	d8c080e7          	jalr	-628(ra) # 56f0 <pipe>
    296c:	e521                	bnez	a0,29b4 <sbrkarg+0xbc>
}
    296e:	70a2                	ld	ra,40(sp)
    2970:	7402                	ld	s0,32(sp)
    2972:	64e2                	ld	s1,24(sp)
    2974:	6942                	ld	s2,16(sp)
    2976:	69a2                	ld	s3,8(sp)
    2978:	6145                	addi	sp,sp,48
    297a:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    297c:	85ce                	mv	a1,s3
    297e:	00004517          	auipc	a0,0x4
    2982:	51250513          	addi	a0,a0,1298 # 6e90 <malloc+0x137a>
    2986:	00003097          	auipc	ra,0x3
    298a:	0d2080e7          	jalr	210(ra) # 5a58 <printf>
    exit(1);
    298e:	4505                	li	a0,1
    2990:	00003097          	auipc	ra,0x3
    2994:	d50080e7          	jalr	-688(ra) # 56e0 <exit>
    printf("%s: write sbrk failed\n", s);
    2998:	85ce                	mv	a1,s3
    299a:	00004517          	auipc	a0,0x4
    299e:	50e50513          	addi	a0,a0,1294 # 6ea8 <malloc+0x1392>
    29a2:	00003097          	auipc	ra,0x3
    29a6:	0b6080e7          	jalr	182(ra) # 5a58 <printf>
    exit(1);
    29aa:	4505                	li	a0,1
    29ac:	00003097          	auipc	ra,0x3
    29b0:	d34080e7          	jalr	-716(ra) # 56e0 <exit>
    printf("%s: pipe() failed\n", s);
    29b4:	85ce                	mv	a1,s3
    29b6:	00004517          	auipc	a0,0x4
    29ba:	ef250513          	addi	a0,a0,-270 # 68a8 <malloc+0xd92>
    29be:	00003097          	auipc	ra,0x3
    29c2:	09a080e7          	jalr	154(ra) # 5a58 <printf>
    exit(1);
    29c6:	4505                	li	a0,1
    29c8:	00003097          	auipc	ra,0x3
    29cc:	d18080e7          	jalr	-744(ra) # 56e0 <exit>

00000000000029d0 <argptest>:
{
    29d0:	1101                	addi	sp,sp,-32
    29d2:	ec06                	sd	ra,24(sp)
    29d4:	e822                	sd	s0,16(sp)
    29d6:	e426                	sd	s1,8(sp)
    29d8:	e04a                	sd	s2,0(sp)
    29da:	1000                	addi	s0,sp,32
    29dc:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    29de:	4581                	li	a1,0
    29e0:	00004517          	auipc	a0,0x4
    29e4:	4e050513          	addi	a0,a0,1248 # 6ec0 <malloc+0x13aa>
    29e8:	00003097          	auipc	ra,0x3
    29ec:	d38080e7          	jalr	-712(ra) # 5720 <open>
  if (fd < 0) {
    29f0:	02054b63          	bltz	a0,2a26 <argptest+0x56>
    29f4:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    29f6:	4501                	li	a0,0
    29f8:	00003097          	auipc	ra,0x3
    29fc:	d70080e7          	jalr	-656(ra) # 5768 <sbrk>
    2a00:	567d                	li	a2,-1
    2a02:	fff50593          	addi	a1,a0,-1
    2a06:	8526                	mv	a0,s1
    2a08:	00003097          	auipc	ra,0x3
    2a0c:	cf0080e7          	jalr	-784(ra) # 56f8 <read>
  close(fd);
    2a10:	8526                	mv	a0,s1
    2a12:	00003097          	auipc	ra,0x3
    2a16:	cf6080e7          	jalr	-778(ra) # 5708 <close>
}
    2a1a:	60e2                	ld	ra,24(sp)
    2a1c:	6442                	ld	s0,16(sp)
    2a1e:	64a2                	ld	s1,8(sp)
    2a20:	6902                	ld	s2,0(sp)
    2a22:	6105                	addi	sp,sp,32
    2a24:	8082                	ret
    printf("%s: open failed\n", s);
    2a26:	85ca                	mv	a1,s2
    2a28:	00004517          	auipc	a0,0x4
    2a2c:	d9050513          	addi	a0,a0,-624 # 67b8 <malloc+0xca2>
    2a30:	00003097          	auipc	ra,0x3
    2a34:	028080e7          	jalr	40(ra) # 5a58 <printf>
    exit(1);
    2a38:	4505                	li	a0,1
    2a3a:	00003097          	auipc	ra,0x3
    2a3e:	ca6080e7          	jalr	-858(ra) # 56e0 <exit>

0000000000002a42 <sbrkbugs>:
{
    2a42:	1141                	addi	sp,sp,-16
    2a44:	e406                	sd	ra,8(sp)
    2a46:	e022                	sd	s0,0(sp)
    2a48:	0800                	addi	s0,sp,16
  int pid = fork();
    2a4a:	00003097          	auipc	ra,0x3
    2a4e:	c8e080e7          	jalr	-882(ra) # 56d8 <fork>
  if(pid < 0){
    2a52:	02054263          	bltz	a0,2a76 <sbrkbugs+0x34>
  if(pid == 0){
    2a56:	ed0d                	bnez	a0,2a90 <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    2a58:	00003097          	auipc	ra,0x3
    2a5c:	d10080e7          	jalr	-752(ra) # 5768 <sbrk>
    sbrk(-sz);
    2a60:	40a0053b          	negw	a0,a0
    2a64:	00003097          	auipc	ra,0x3
    2a68:	d04080e7          	jalr	-764(ra) # 5768 <sbrk>
    exit(0);
    2a6c:	4501                	li	a0,0
    2a6e:	00003097          	auipc	ra,0x3
    2a72:	c72080e7          	jalr	-910(ra) # 56e0 <exit>
    printf("fork failed\n");
    2a76:	00004517          	auipc	a0,0x4
    2a7a:	13250513          	addi	a0,a0,306 # 6ba8 <malloc+0x1092>
    2a7e:	00003097          	auipc	ra,0x3
    2a82:	fda080e7          	jalr	-38(ra) # 5a58 <printf>
    exit(1);
    2a86:	4505                	li	a0,1
    2a88:	00003097          	auipc	ra,0x3
    2a8c:	c58080e7          	jalr	-936(ra) # 56e0 <exit>
  wait(0);
    2a90:	4501                	li	a0,0
    2a92:	00003097          	auipc	ra,0x3
    2a96:	c56080e7          	jalr	-938(ra) # 56e8 <wait>
  pid = fork();
    2a9a:	00003097          	auipc	ra,0x3
    2a9e:	c3e080e7          	jalr	-962(ra) # 56d8 <fork>
  if(pid < 0){
    2aa2:	02054563          	bltz	a0,2acc <sbrkbugs+0x8a>
  if(pid == 0){
    2aa6:	e121                	bnez	a0,2ae6 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    2aa8:	00003097          	auipc	ra,0x3
    2aac:	cc0080e7          	jalr	-832(ra) # 5768 <sbrk>
    sbrk(-(sz - 3500));
    2ab0:	6785                	lui	a5,0x1
    2ab2:	dac7879b          	addiw	a5,a5,-596
    2ab6:	40a7853b          	subw	a0,a5,a0
    2aba:	00003097          	auipc	ra,0x3
    2abe:	cae080e7          	jalr	-850(ra) # 5768 <sbrk>
    exit(0);
    2ac2:	4501                	li	a0,0
    2ac4:	00003097          	auipc	ra,0x3
    2ac8:	c1c080e7          	jalr	-996(ra) # 56e0 <exit>
    printf("fork failed\n");
    2acc:	00004517          	auipc	a0,0x4
    2ad0:	0dc50513          	addi	a0,a0,220 # 6ba8 <malloc+0x1092>
    2ad4:	00003097          	auipc	ra,0x3
    2ad8:	f84080e7          	jalr	-124(ra) # 5a58 <printf>
    exit(1);
    2adc:	4505                	li	a0,1
    2ade:	00003097          	auipc	ra,0x3
    2ae2:	c02080e7          	jalr	-1022(ra) # 56e0 <exit>
  wait(0);
    2ae6:	4501                	li	a0,0
    2ae8:	00003097          	auipc	ra,0x3
    2aec:	c00080e7          	jalr	-1024(ra) # 56e8 <wait>
  pid = fork();
    2af0:	00003097          	auipc	ra,0x3
    2af4:	be8080e7          	jalr	-1048(ra) # 56d8 <fork>
  if(pid < 0){
    2af8:	02054a63          	bltz	a0,2b2c <sbrkbugs+0xea>
  if(pid == 0){
    2afc:	e529                	bnez	a0,2b46 <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    2afe:	00003097          	auipc	ra,0x3
    2b02:	c6a080e7          	jalr	-918(ra) # 5768 <sbrk>
    2b06:	67ad                	lui	a5,0xb
    2b08:	8007879b          	addiw	a5,a5,-2048
    2b0c:	40a7853b          	subw	a0,a5,a0
    2b10:	00003097          	auipc	ra,0x3
    2b14:	c58080e7          	jalr	-936(ra) # 5768 <sbrk>
    sbrk(-10);
    2b18:	5559                	li	a0,-10
    2b1a:	00003097          	auipc	ra,0x3
    2b1e:	c4e080e7          	jalr	-946(ra) # 5768 <sbrk>
    exit(0);
    2b22:	4501                	li	a0,0
    2b24:	00003097          	auipc	ra,0x3
    2b28:	bbc080e7          	jalr	-1092(ra) # 56e0 <exit>
    printf("fork failed\n");
    2b2c:	00004517          	auipc	a0,0x4
    2b30:	07c50513          	addi	a0,a0,124 # 6ba8 <malloc+0x1092>
    2b34:	00003097          	auipc	ra,0x3
    2b38:	f24080e7          	jalr	-220(ra) # 5a58 <printf>
    exit(1);
    2b3c:	4505                	li	a0,1
    2b3e:	00003097          	auipc	ra,0x3
    2b42:	ba2080e7          	jalr	-1118(ra) # 56e0 <exit>
  wait(0);
    2b46:	4501                	li	a0,0
    2b48:	00003097          	auipc	ra,0x3
    2b4c:	ba0080e7          	jalr	-1120(ra) # 56e8 <wait>
  exit(0);
    2b50:	4501                	li	a0,0
    2b52:	00003097          	auipc	ra,0x3
    2b56:	b8e080e7          	jalr	-1138(ra) # 56e0 <exit>

0000000000002b5a <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    2b5a:	715d                	addi	sp,sp,-80
    2b5c:	e486                	sd	ra,72(sp)
    2b5e:	e0a2                	sd	s0,64(sp)
    2b60:	fc26                	sd	s1,56(sp)
    2b62:	f84a                	sd	s2,48(sp)
    2b64:	f44e                	sd	s3,40(sp)
    2b66:	f052                	sd	s4,32(sp)
    2b68:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2b6a:	4901                	li	s2,0
    2b6c:	49bd                	li	s3,15
    int pid = fork();
    2b6e:	00003097          	auipc	ra,0x3
    2b72:	b6a080e7          	jalr	-1174(ra) # 56d8 <fork>
    2b76:	84aa                	mv	s1,a0
    if(pid < 0){
    2b78:	02054063          	bltz	a0,2b98 <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
    2b7c:	c91d                	beqz	a0,2bb2 <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
    2b7e:	4501                	li	a0,0
    2b80:	00003097          	auipc	ra,0x3
    2b84:	b68080e7          	jalr	-1176(ra) # 56e8 <wait>
  for(int avail = 0; avail < 15; avail++){
    2b88:	2905                	addiw	s2,s2,1
    2b8a:	ff3912e3          	bne	s2,s3,2b6e <execout+0x14>
    }
  }

  exit(0);
    2b8e:	4501                	li	a0,0
    2b90:	00003097          	auipc	ra,0x3
    2b94:	b50080e7          	jalr	-1200(ra) # 56e0 <exit>
      printf("fork failed\n");
    2b98:	00004517          	auipc	a0,0x4
    2b9c:	01050513          	addi	a0,a0,16 # 6ba8 <malloc+0x1092>
    2ba0:	00003097          	auipc	ra,0x3
    2ba4:	eb8080e7          	jalr	-328(ra) # 5a58 <printf>
      exit(1);
    2ba8:	4505                	li	a0,1
    2baa:	00003097          	auipc	ra,0x3
    2bae:	b36080e7          	jalr	-1226(ra) # 56e0 <exit>
        if(a == 0xffffffffffffffffLL)
    2bb2:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2bb4:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2bb6:	6505                	lui	a0,0x1
    2bb8:	00003097          	auipc	ra,0x3
    2bbc:	bb0080e7          	jalr	-1104(ra) # 5768 <sbrk>
        if(a == 0xffffffffffffffffLL)
    2bc0:	01350763          	beq	a0,s3,2bce <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2bc4:	6785                	lui	a5,0x1
    2bc6:	953e                	add	a0,a0,a5
    2bc8:	ff450fa3          	sb	s4,-1(a0) # fff <bigdir+0x9d>
      while(1){
    2bcc:	b7ed                	j	2bb6 <execout+0x5c>
      for(int i = 0; i < avail; i++)
    2bce:	01205a63          	blez	s2,2be2 <execout+0x88>
        sbrk(-4096);
    2bd2:	757d                	lui	a0,0xfffff
    2bd4:	00003097          	auipc	ra,0x3
    2bd8:	b94080e7          	jalr	-1132(ra) # 5768 <sbrk>
      for(int i = 0; i < avail; i++)
    2bdc:	2485                	addiw	s1,s1,1
    2bde:	ff249ae3          	bne	s1,s2,2bd2 <execout+0x78>
      close(1);
    2be2:	4505                	li	a0,1
    2be4:	00003097          	auipc	ra,0x3
    2be8:	b24080e7          	jalr	-1244(ra) # 5708 <close>
      char *args[] = { "echo", "x", 0 };
    2bec:	00003517          	auipc	a0,0x3
    2bf0:	37c50513          	addi	a0,a0,892 # 5f68 <malloc+0x452>
    2bf4:	faa43c23          	sd	a0,-72(s0)
    2bf8:	00003797          	auipc	a5,0x3
    2bfc:	3e078793          	addi	a5,a5,992 # 5fd8 <malloc+0x4c2>
    2c00:	fcf43023          	sd	a5,-64(s0)
    2c04:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2c08:	fb840593          	addi	a1,s0,-72
    2c0c:	00003097          	auipc	ra,0x3
    2c10:	b0c080e7          	jalr	-1268(ra) # 5718 <exec>
      exit(0);
    2c14:	4501                	li	a0,0
    2c16:	00003097          	auipc	ra,0x3
    2c1a:	aca080e7          	jalr	-1334(ra) # 56e0 <exit>

0000000000002c1e <fourteen>:
{
    2c1e:	1101                	addi	sp,sp,-32
    2c20:	ec06                	sd	ra,24(sp)
    2c22:	e822                	sd	s0,16(sp)
    2c24:	e426                	sd	s1,8(sp)
    2c26:	1000                	addi	s0,sp,32
    2c28:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2c2a:	00004517          	auipc	a0,0x4
    2c2e:	46e50513          	addi	a0,a0,1134 # 7098 <malloc+0x1582>
    2c32:	00003097          	auipc	ra,0x3
    2c36:	b16080e7          	jalr	-1258(ra) # 5748 <mkdir>
    2c3a:	e165                	bnez	a0,2d1a <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    2c3c:	00004517          	auipc	a0,0x4
    2c40:	2b450513          	addi	a0,a0,692 # 6ef0 <malloc+0x13da>
    2c44:	00003097          	auipc	ra,0x3
    2c48:	b04080e7          	jalr	-1276(ra) # 5748 <mkdir>
    2c4c:	e56d                	bnez	a0,2d36 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2c4e:	20000593          	li	a1,512
    2c52:	00004517          	auipc	a0,0x4
    2c56:	2f650513          	addi	a0,a0,758 # 6f48 <malloc+0x1432>
    2c5a:	00003097          	auipc	ra,0x3
    2c5e:	ac6080e7          	jalr	-1338(ra) # 5720 <open>
  if(fd < 0){
    2c62:	0e054863          	bltz	a0,2d52 <fourteen+0x134>
  close(fd);
    2c66:	00003097          	auipc	ra,0x3
    2c6a:	aa2080e7          	jalr	-1374(ra) # 5708 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2c6e:	4581                	li	a1,0
    2c70:	00004517          	auipc	a0,0x4
    2c74:	35050513          	addi	a0,a0,848 # 6fc0 <malloc+0x14aa>
    2c78:	00003097          	auipc	ra,0x3
    2c7c:	aa8080e7          	jalr	-1368(ra) # 5720 <open>
  if(fd < 0){
    2c80:	0e054763          	bltz	a0,2d6e <fourteen+0x150>
  close(fd);
    2c84:	00003097          	auipc	ra,0x3
    2c88:	a84080e7          	jalr	-1404(ra) # 5708 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    2c8c:	00004517          	auipc	a0,0x4
    2c90:	3a450513          	addi	a0,a0,932 # 7030 <malloc+0x151a>
    2c94:	00003097          	auipc	ra,0x3
    2c98:	ab4080e7          	jalr	-1356(ra) # 5748 <mkdir>
    2c9c:	c57d                	beqz	a0,2d8a <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    2c9e:	00004517          	auipc	a0,0x4
    2ca2:	3ea50513          	addi	a0,a0,1002 # 7088 <malloc+0x1572>
    2ca6:	00003097          	auipc	ra,0x3
    2caa:	aa2080e7          	jalr	-1374(ra) # 5748 <mkdir>
    2cae:	cd65                	beqz	a0,2da6 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    2cb0:	00004517          	auipc	a0,0x4
    2cb4:	3d850513          	addi	a0,a0,984 # 7088 <malloc+0x1572>
    2cb8:	00003097          	auipc	ra,0x3
    2cbc:	a78080e7          	jalr	-1416(ra) # 5730 <unlink>
  unlink("12345678901234/12345678901234");
    2cc0:	00004517          	auipc	a0,0x4
    2cc4:	37050513          	addi	a0,a0,880 # 7030 <malloc+0x151a>
    2cc8:	00003097          	auipc	ra,0x3
    2ccc:	a68080e7          	jalr	-1432(ra) # 5730 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    2cd0:	00004517          	auipc	a0,0x4
    2cd4:	2f050513          	addi	a0,a0,752 # 6fc0 <malloc+0x14aa>
    2cd8:	00003097          	auipc	ra,0x3
    2cdc:	a58080e7          	jalr	-1448(ra) # 5730 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    2ce0:	00004517          	auipc	a0,0x4
    2ce4:	26850513          	addi	a0,a0,616 # 6f48 <malloc+0x1432>
    2ce8:	00003097          	auipc	ra,0x3
    2cec:	a48080e7          	jalr	-1464(ra) # 5730 <unlink>
  unlink("12345678901234/123456789012345");
    2cf0:	00004517          	auipc	a0,0x4
    2cf4:	20050513          	addi	a0,a0,512 # 6ef0 <malloc+0x13da>
    2cf8:	00003097          	auipc	ra,0x3
    2cfc:	a38080e7          	jalr	-1480(ra) # 5730 <unlink>
  unlink("12345678901234");
    2d00:	00004517          	auipc	a0,0x4
    2d04:	39850513          	addi	a0,a0,920 # 7098 <malloc+0x1582>
    2d08:	00003097          	auipc	ra,0x3
    2d0c:	a28080e7          	jalr	-1496(ra) # 5730 <unlink>
}
    2d10:	60e2                	ld	ra,24(sp)
    2d12:	6442                	ld	s0,16(sp)
    2d14:	64a2                	ld	s1,8(sp)
    2d16:	6105                	addi	sp,sp,32
    2d18:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    2d1a:	85a6                	mv	a1,s1
    2d1c:	00004517          	auipc	a0,0x4
    2d20:	1ac50513          	addi	a0,a0,428 # 6ec8 <malloc+0x13b2>
    2d24:	00003097          	auipc	ra,0x3
    2d28:	d34080e7          	jalr	-716(ra) # 5a58 <printf>
    exit(1);
    2d2c:	4505                	li	a0,1
    2d2e:	00003097          	auipc	ra,0x3
    2d32:	9b2080e7          	jalr	-1614(ra) # 56e0 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    2d36:	85a6                	mv	a1,s1
    2d38:	00004517          	auipc	a0,0x4
    2d3c:	1d850513          	addi	a0,a0,472 # 6f10 <malloc+0x13fa>
    2d40:	00003097          	auipc	ra,0x3
    2d44:	d18080e7          	jalr	-744(ra) # 5a58 <printf>
    exit(1);
    2d48:	4505                	li	a0,1
    2d4a:	00003097          	auipc	ra,0x3
    2d4e:	996080e7          	jalr	-1642(ra) # 56e0 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2d52:	85a6                	mv	a1,s1
    2d54:	00004517          	auipc	a0,0x4
    2d58:	22450513          	addi	a0,a0,548 # 6f78 <malloc+0x1462>
    2d5c:	00003097          	auipc	ra,0x3
    2d60:	cfc080e7          	jalr	-772(ra) # 5a58 <printf>
    exit(1);
    2d64:	4505                	li	a0,1
    2d66:	00003097          	auipc	ra,0x3
    2d6a:	97a080e7          	jalr	-1670(ra) # 56e0 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2d6e:	85a6                	mv	a1,s1
    2d70:	00004517          	auipc	a0,0x4
    2d74:	28050513          	addi	a0,a0,640 # 6ff0 <malloc+0x14da>
    2d78:	00003097          	auipc	ra,0x3
    2d7c:	ce0080e7          	jalr	-800(ra) # 5a58 <printf>
    exit(1);
    2d80:	4505                	li	a0,1
    2d82:	00003097          	auipc	ra,0x3
    2d86:	95e080e7          	jalr	-1698(ra) # 56e0 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    2d8a:	85a6                	mv	a1,s1
    2d8c:	00004517          	auipc	a0,0x4
    2d90:	2c450513          	addi	a0,a0,708 # 7050 <malloc+0x153a>
    2d94:	00003097          	auipc	ra,0x3
    2d98:	cc4080e7          	jalr	-828(ra) # 5a58 <printf>
    exit(1);
    2d9c:	4505                	li	a0,1
    2d9e:	00003097          	auipc	ra,0x3
    2da2:	942080e7          	jalr	-1726(ra) # 56e0 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    2da6:	85a6                	mv	a1,s1
    2da8:	00004517          	auipc	a0,0x4
    2dac:	30050513          	addi	a0,a0,768 # 70a8 <malloc+0x1592>
    2db0:	00003097          	auipc	ra,0x3
    2db4:	ca8080e7          	jalr	-856(ra) # 5a58 <printf>
    exit(1);
    2db8:	4505                	li	a0,1
    2dba:	00003097          	auipc	ra,0x3
    2dbe:	926080e7          	jalr	-1754(ra) # 56e0 <exit>

0000000000002dc2 <iputtest>:
{
    2dc2:	1101                	addi	sp,sp,-32
    2dc4:	ec06                	sd	ra,24(sp)
    2dc6:	e822                	sd	s0,16(sp)
    2dc8:	e426                	sd	s1,8(sp)
    2dca:	1000                	addi	s0,sp,32
    2dcc:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2dce:	00004517          	auipc	a0,0x4
    2dd2:	31250513          	addi	a0,a0,786 # 70e0 <malloc+0x15ca>
    2dd6:	00003097          	auipc	ra,0x3
    2dda:	972080e7          	jalr	-1678(ra) # 5748 <mkdir>
    2dde:	04054563          	bltz	a0,2e28 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    2de2:	00004517          	auipc	a0,0x4
    2de6:	2fe50513          	addi	a0,a0,766 # 70e0 <malloc+0x15ca>
    2dea:	00003097          	auipc	ra,0x3
    2dee:	966080e7          	jalr	-1690(ra) # 5750 <chdir>
    2df2:	04054963          	bltz	a0,2e44 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    2df6:	00004517          	auipc	a0,0x4
    2dfa:	32a50513          	addi	a0,a0,810 # 7120 <malloc+0x160a>
    2dfe:	00003097          	auipc	ra,0x3
    2e02:	932080e7          	jalr	-1742(ra) # 5730 <unlink>
    2e06:	04054d63          	bltz	a0,2e60 <iputtest+0x9e>
  if(chdir("/") < 0){
    2e0a:	00004517          	auipc	a0,0x4
    2e0e:	34650513          	addi	a0,a0,838 # 7150 <malloc+0x163a>
    2e12:	00003097          	auipc	ra,0x3
    2e16:	93e080e7          	jalr	-1730(ra) # 5750 <chdir>
    2e1a:	06054163          	bltz	a0,2e7c <iputtest+0xba>
}
    2e1e:	60e2                	ld	ra,24(sp)
    2e20:	6442                	ld	s0,16(sp)
    2e22:	64a2                	ld	s1,8(sp)
    2e24:	6105                	addi	sp,sp,32
    2e26:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2e28:	85a6                	mv	a1,s1
    2e2a:	00004517          	auipc	a0,0x4
    2e2e:	2be50513          	addi	a0,a0,702 # 70e8 <malloc+0x15d2>
    2e32:	00003097          	auipc	ra,0x3
    2e36:	c26080e7          	jalr	-986(ra) # 5a58 <printf>
    exit(1);
    2e3a:	4505                	li	a0,1
    2e3c:	00003097          	auipc	ra,0x3
    2e40:	8a4080e7          	jalr	-1884(ra) # 56e0 <exit>
    printf("%s: chdir iputdir failed\n", s);
    2e44:	85a6                	mv	a1,s1
    2e46:	00004517          	auipc	a0,0x4
    2e4a:	2ba50513          	addi	a0,a0,698 # 7100 <malloc+0x15ea>
    2e4e:	00003097          	auipc	ra,0x3
    2e52:	c0a080e7          	jalr	-1014(ra) # 5a58 <printf>
    exit(1);
    2e56:	4505                	li	a0,1
    2e58:	00003097          	auipc	ra,0x3
    2e5c:	888080e7          	jalr	-1912(ra) # 56e0 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    2e60:	85a6                	mv	a1,s1
    2e62:	00004517          	auipc	a0,0x4
    2e66:	2ce50513          	addi	a0,a0,718 # 7130 <malloc+0x161a>
    2e6a:	00003097          	auipc	ra,0x3
    2e6e:	bee080e7          	jalr	-1042(ra) # 5a58 <printf>
    exit(1);
    2e72:	4505                	li	a0,1
    2e74:	00003097          	auipc	ra,0x3
    2e78:	86c080e7          	jalr	-1940(ra) # 56e0 <exit>
    printf("%s: chdir / failed\n", s);
    2e7c:	85a6                	mv	a1,s1
    2e7e:	00004517          	auipc	a0,0x4
    2e82:	2da50513          	addi	a0,a0,730 # 7158 <malloc+0x1642>
    2e86:	00003097          	auipc	ra,0x3
    2e8a:	bd2080e7          	jalr	-1070(ra) # 5a58 <printf>
    exit(1);
    2e8e:	4505                	li	a0,1
    2e90:	00003097          	auipc	ra,0x3
    2e94:	850080e7          	jalr	-1968(ra) # 56e0 <exit>

0000000000002e98 <exitiputtest>:
{
    2e98:	7179                	addi	sp,sp,-48
    2e9a:	f406                	sd	ra,40(sp)
    2e9c:	f022                	sd	s0,32(sp)
    2e9e:	ec26                	sd	s1,24(sp)
    2ea0:	1800                	addi	s0,sp,48
    2ea2:	84aa                	mv	s1,a0
  pid = fork();
    2ea4:	00003097          	auipc	ra,0x3
    2ea8:	834080e7          	jalr	-1996(ra) # 56d8 <fork>
  if(pid < 0){
    2eac:	04054663          	bltz	a0,2ef8 <exitiputtest+0x60>
  if(pid == 0){
    2eb0:	ed45                	bnez	a0,2f68 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    2eb2:	00004517          	auipc	a0,0x4
    2eb6:	22e50513          	addi	a0,a0,558 # 70e0 <malloc+0x15ca>
    2eba:	00003097          	auipc	ra,0x3
    2ebe:	88e080e7          	jalr	-1906(ra) # 5748 <mkdir>
    2ec2:	04054963          	bltz	a0,2f14 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    2ec6:	00004517          	auipc	a0,0x4
    2eca:	21a50513          	addi	a0,a0,538 # 70e0 <malloc+0x15ca>
    2ece:	00003097          	auipc	ra,0x3
    2ed2:	882080e7          	jalr	-1918(ra) # 5750 <chdir>
    2ed6:	04054d63          	bltz	a0,2f30 <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    2eda:	00004517          	auipc	a0,0x4
    2ede:	24650513          	addi	a0,a0,582 # 7120 <malloc+0x160a>
    2ee2:	00003097          	auipc	ra,0x3
    2ee6:	84e080e7          	jalr	-1970(ra) # 5730 <unlink>
    2eea:	06054163          	bltz	a0,2f4c <exitiputtest+0xb4>
    exit(0);
    2eee:	4501                	li	a0,0
    2ef0:	00002097          	auipc	ra,0x2
    2ef4:	7f0080e7          	jalr	2032(ra) # 56e0 <exit>
    printf("%s: fork failed\n", s);
    2ef8:	85a6                	mv	a1,s1
    2efa:	00004517          	auipc	a0,0x4
    2efe:	8a650513          	addi	a0,a0,-1882 # 67a0 <malloc+0xc8a>
    2f02:	00003097          	auipc	ra,0x3
    2f06:	b56080e7          	jalr	-1194(ra) # 5a58 <printf>
    exit(1);
    2f0a:	4505                	li	a0,1
    2f0c:	00002097          	auipc	ra,0x2
    2f10:	7d4080e7          	jalr	2004(ra) # 56e0 <exit>
      printf("%s: mkdir failed\n", s);
    2f14:	85a6                	mv	a1,s1
    2f16:	00004517          	auipc	a0,0x4
    2f1a:	1d250513          	addi	a0,a0,466 # 70e8 <malloc+0x15d2>
    2f1e:	00003097          	auipc	ra,0x3
    2f22:	b3a080e7          	jalr	-1222(ra) # 5a58 <printf>
      exit(1);
    2f26:	4505                	li	a0,1
    2f28:	00002097          	auipc	ra,0x2
    2f2c:	7b8080e7          	jalr	1976(ra) # 56e0 <exit>
      printf("%s: child chdir failed\n", s);
    2f30:	85a6                	mv	a1,s1
    2f32:	00004517          	auipc	a0,0x4
    2f36:	23e50513          	addi	a0,a0,574 # 7170 <malloc+0x165a>
    2f3a:	00003097          	auipc	ra,0x3
    2f3e:	b1e080e7          	jalr	-1250(ra) # 5a58 <printf>
      exit(1);
    2f42:	4505                	li	a0,1
    2f44:	00002097          	auipc	ra,0x2
    2f48:	79c080e7          	jalr	1948(ra) # 56e0 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2f4c:	85a6                	mv	a1,s1
    2f4e:	00004517          	auipc	a0,0x4
    2f52:	1e250513          	addi	a0,a0,482 # 7130 <malloc+0x161a>
    2f56:	00003097          	auipc	ra,0x3
    2f5a:	b02080e7          	jalr	-1278(ra) # 5a58 <printf>
      exit(1);
    2f5e:	4505                	li	a0,1
    2f60:	00002097          	auipc	ra,0x2
    2f64:	780080e7          	jalr	1920(ra) # 56e0 <exit>
  wait(&xstatus);
    2f68:	fdc40513          	addi	a0,s0,-36
    2f6c:	00002097          	auipc	ra,0x2
    2f70:	77c080e7          	jalr	1916(ra) # 56e8 <wait>
  exit(xstatus);
    2f74:	fdc42503          	lw	a0,-36(s0)
    2f78:	00002097          	auipc	ra,0x2
    2f7c:	768080e7          	jalr	1896(ra) # 56e0 <exit>

0000000000002f80 <dirtest>:
{
    2f80:	1101                	addi	sp,sp,-32
    2f82:	ec06                	sd	ra,24(sp)
    2f84:	e822                	sd	s0,16(sp)
    2f86:	e426                	sd	s1,8(sp)
    2f88:	1000                	addi	s0,sp,32
    2f8a:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    2f8c:	00004517          	auipc	a0,0x4
    2f90:	1fc50513          	addi	a0,a0,508 # 7188 <malloc+0x1672>
    2f94:	00002097          	auipc	ra,0x2
    2f98:	7b4080e7          	jalr	1972(ra) # 5748 <mkdir>
    2f9c:	04054563          	bltz	a0,2fe6 <dirtest+0x66>
  if(chdir("dir0") < 0){
    2fa0:	00004517          	auipc	a0,0x4
    2fa4:	1e850513          	addi	a0,a0,488 # 7188 <malloc+0x1672>
    2fa8:	00002097          	auipc	ra,0x2
    2fac:	7a8080e7          	jalr	1960(ra) # 5750 <chdir>
    2fb0:	04054963          	bltz	a0,3002 <dirtest+0x82>
  if(chdir("..") < 0){
    2fb4:	00004517          	auipc	a0,0x4
    2fb8:	1f450513          	addi	a0,a0,500 # 71a8 <malloc+0x1692>
    2fbc:	00002097          	auipc	ra,0x2
    2fc0:	794080e7          	jalr	1940(ra) # 5750 <chdir>
    2fc4:	04054d63          	bltz	a0,301e <dirtest+0x9e>
  if(unlink("dir0") < 0){
    2fc8:	00004517          	auipc	a0,0x4
    2fcc:	1c050513          	addi	a0,a0,448 # 7188 <malloc+0x1672>
    2fd0:	00002097          	auipc	ra,0x2
    2fd4:	760080e7          	jalr	1888(ra) # 5730 <unlink>
    2fd8:	06054163          	bltz	a0,303a <dirtest+0xba>
}
    2fdc:	60e2                	ld	ra,24(sp)
    2fde:	6442                	ld	s0,16(sp)
    2fe0:	64a2                	ld	s1,8(sp)
    2fe2:	6105                	addi	sp,sp,32
    2fe4:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2fe6:	85a6                	mv	a1,s1
    2fe8:	00004517          	auipc	a0,0x4
    2fec:	10050513          	addi	a0,a0,256 # 70e8 <malloc+0x15d2>
    2ff0:	00003097          	auipc	ra,0x3
    2ff4:	a68080e7          	jalr	-1432(ra) # 5a58 <printf>
    exit(1);
    2ff8:	4505                	li	a0,1
    2ffa:	00002097          	auipc	ra,0x2
    2ffe:	6e6080e7          	jalr	1766(ra) # 56e0 <exit>
    printf("%s: chdir dir0 failed\n", s);
    3002:	85a6                	mv	a1,s1
    3004:	00004517          	auipc	a0,0x4
    3008:	18c50513          	addi	a0,a0,396 # 7190 <malloc+0x167a>
    300c:	00003097          	auipc	ra,0x3
    3010:	a4c080e7          	jalr	-1460(ra) # 5a58 <printf>
    exit(1);
    3014:	4505                	li	a0,1
    3016:	00002097          	auipc	ra,0x2
    301a:	6ca080e7          	jalr	1738(ra) # 56e0 <exit>
    printf("%s: chdir .. failed\n", s);
    301e:	85a6                	mv	a1,s1
    3020:	00004517          	auipc	a0,0x4
    3024:	19050513          	addi	a0,a0,400 # 71b0 <malloc+0x169a>
    3028:	00003097          	auipc	ra,0x3
    302c:	a30080e7          	jalr	-1488(ra) # 5a58 <printf>
    exit(1);
    3030:	4505                	li	a0,1
    3032:	00002097          	auipc	ra,0x2
    3036:	6ae080e7          	jalr	1710(ra) # 56e0 <exit>
    printf("%s: unlink dir0 failed\n", s);
    303a:	85a6                	mv	a1,s1
    303c:	00004517          	auipc	a0,0x4
    3040:	18c50513          	addi	a0,a0,396 # 71c8 <malloc+0x16b2>
    3044:	00003097          	auipc	ra,0x3
    3048:	a14080e7          	jalr	-1516(ra) # 5a58 <printf>
    exit(1);
    304c:	4505                	li	a0,1
    304e:	00002097          	auipc	ra,0x2
    3052:	692080e7          	jalr	1682(ra) # 56e0 <exit>

0000000000003056 <subdir>:
{
    3056:	1101                	addi	sp,sp,-32
    3058:	ec06                	sd	ra,24(sp)
    305a:	e822                	sd	s0,16(sp)
    305c:	e426                	sd	s1,8(sp)
    305e:	e04a                	sd	s2,0(sp)
    3060:	1000                	addi	s0,sp,32
    3062:	892a                	mv	s2,a0
  unlink("ff");
    3064:	00004517          	auipc	a0,0x4
    3068:	2ac50513          	addi	a0,a0,684 # 7310 <malloc+0x17fa>
    306c:	00002097          	auipc	ra,0x2
    3070:	6c4080e7          	jalr	1732(ra) # 5730 <unlink>
  if(mkdir("dd") != 0){
    3074:	00004517          	auipc	a0,0x4
    3078:	16c50513          	addi	a0,a0,364 # 71e0 <malloc+0x16ca>
    307c:	00002097          	auipc	ra,0x2
    3080:	6cc080e7          	jalr	1740(ra) # 5748 <mkdir>
    3084:	38051663          	bnez	a0,3410 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    3088:	20200593          	li	a1,514
    308c:	00004517          	auipc	a0,0x4
    3090:	17450513          	addi	a0,a0,372 # 7200 <malloc+0x16ea>
    3094:	00002097          	auipc	ra,0x2
    3098:	68c080e7          	jalr	1676(ra) # 5720 <open>
    309c:	84aa                	mv	s1,a0
  if(fd < 0){
    309e:	38054763          	bltz	a0,342c <subdir+0x3d6>
  write(fd, "ff", 2);
    30a2:	4609                	li	a2,2
    30a4:	00004597          	auipc	a1,0x4
    30a8:	26c58593          	addi	a1,a1,620 # 7310 <malloc+0x17fa>
    30ac:	00002097          	auipc	ra,0x2
    30b0:	654080e7          	jalr	1620(ra) # 5700 <write>
  close(fd);
    30b4:	8526                	mv	a0,s1
    30b6:	00002097          	auipc	ra,0x2
    30ba:	652080e7          	jalr	1618(ra) # 5708 <close>
  if(unlink("dd") >= 0){
    30be:	00004517          	auipc	a0,0x4
    30c2:	12250513          	addi	a0,a0,290 # 71e0 <malloc+0x16ca>
    30c6:	00002097          	auipc	ra,0x2
    30ca:	66a080e7          	jalr	1642(ra) # 5730 <unlink>
    30ce:	36055d63          	bgez	a0,3448 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    30d2:	00004517          	auipc	a0,0x4
    30d6:	18650513          	addi	a0,a0,390 # 7258 <malloc+0x1742>
    30da:	00002097          	auipc	ra,0x2
    30de:	66e080e7          	jalr	1646(ra) # 5748 <mkdir>
    30e2:	38051163          	bnez	a0,3464 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    30e6:	20200593          	li	a1,514
    30ea:	00004517          	auipc	a0,0x4
    30ee:	19650513          	addi	a0,a0,406 # 7280 <malloc+0x176a>
    30f2:	00002097          	auipc	ra,0x2
    30f6:	62e080e7          	jalr	1582(ra) # 5720 <open>
    30fa:	84aa                	mv	s1,a0
  if(fd < 0){
    30fc:	38054263          	bltz	a0,3480 <subdir+0x42a>
  write(fd, "FF", 2);
    3100:	4609                	li	a2,2
    3102:	00004597          	auipc	a1,0x4
    3106:	1ae58593          	addi	a1,a1,430 # 72b0 <malloc+0x179a>
    310a:	00002097          	auipc	ra,0x2
    310e:	5f6080e7          	jalr	1526(ra) # 5700 <write>
  close(fd);
    3112:	8526                	mv	a0,s1
    3114:	00002097          	auipc	ra,0x2
    3118:	5f4080e7          	jalr	1524(ra) # 5708 <close>
  fd = open("dd/dd/../ff", 0);
    311c:	4581                	li	a1,0
    311e:	00004517          	auipc	a0,0x4
    3122:	19a50513          	addi	a0,a0,410 # 72b8 <malloc+0x17a2>
    3126:	00002097          	auipc	ra,0x2
    312a:	5fa080e7          	jalr	1530(ra) # 5720 <open>
    312e:	84aa                	mv	s1,a0
  if(fd < 0){
    3130:	36054663          	bltz	a0,349c <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    3134:	660d                	lui	a2,0x3
    3136:	00009597          	auipc	a1,0x9
    313a:	a9a58593          	addi	a1,a1,-1382 # bbd0 <buf>
    313e:	00002097          	auipc	ra,0x2
    3142:	5ba080e7          	jalr	1466(ra) # 56f8 <read>
  if(cc != 2 || buf[0] != 'f'){
    3146:	4789                	li	a5,2
    3148:	36f51863          	bne	a0,a5,34b8 <subdir+0x462>
    314c:	00009717          	auipc	a4,0x9
    3150:	a8474703          	lbu	a4,-1404(a4) # bbd0 <buf>
    3154:	06600793          	li	a5,102
    3158:	36f71063          	bne	a4,a5,34b8 <subdir+0x462>
  close(fd);
    315c:	8526                	mv	a0,s1
    315e:	00002097          	auipc	ra,0x2
    3162:	5aa080e7          	jalr	1450(ra) # 5708 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    3166:	00004597          	auipc	a1,0x4
    316a:	1a258593          	addi	a1,a1,418 # 7308 <malloc+0x17f2>
    316e:	00004517          	auipc	a0,0x4
    3172:	11250513          	addi	a0,a0,274 # 7280 <malloc+0x176a>
    3176:	00002097          	auipc	ra,0x2
    317a:	5ca080e7          	jalr	1482(ra) # 5740 <link>
    317e:	34051b63          	bnez	a0,34d4 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    3182:	00004517          	auipc	a0,0x4
    3186:	0fe50513          	addi	a0,a0,254 # 7280 <malloc+0x176a>
    318a:	00002097          	auipc	ra,0x2
    318e:	5a6080e7          	jalr	1446(ra) # 5730 <unlink>
    3192:	34051f63          	bnez	a0,34f0 <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3196:	4581                	li	a1,0
    3198:	00004517          	auipc	a0,0x4
    319c:	0e850513          	addi	a0,a0,232 # 7280 <malloc+0x176a>
    31a0:	00002097          	auipc	ra,0x2
    31a4:	580080e7          	jalr	1408(ra) # 5720 <open>
    31a8:	36055263          	bgez	a0,350c <subdir+0x4b6>
  if(chdir("dd") != 0){
    31ac:	00004517          	auipc	a0,0x4
    31b0:	03450513          	addi	a0,a0,52 # 71e0 <malloc+0x16ca>
    31b4:	00002097          	auipc	ra,0x2
    31b8:	59c080e7          	jalr	1436(ra) # 5750 <chdir>
    31bc:	36051663          	bnez	a0,3528 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    31c0:	00004517          	auipc	a0,0x4
    31c4:	1e050513          	addi	a0,a0,480 # 73a0 <malloc+0x188a>
    31c8:	00002097          	auipc	ra,0x2
    31cc:	588080e7          	jalr	1416(ra) # 5750 <chdir>
    31d0:	36051a63          	bnez	a0,3544 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    31d4:	00004517          	auipc	a0,0x4
    31d8:	1fc50513          	addi	a0,a0,508 # 73d0 <malloc+0x18ba>
    31dc:	00002097          	auipc	ra,0x2
    31e0:	574080e7          	jalr	1396(ra) # 5750 <chdir>
    31e4:	36051e63          	bnez	a0,3560 <subdir+0x50a>
  if(chdir("./..") != 0){
    31e8:	00004517          	auipc	a0,0x4
    31ec:	21850513          	addi	a0,a0,536 # 7400 <malloc+0x18ea>
    31f0:	00002097          	auipc	ra,0x2
    31f4:	560080e7          	jalr	1376(ra) # 5750 <chdir>
    31f8:	38051263          	bnez	a0,357c <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    31fc:	4581                	li	a1,0
    31fe:	00004517          	auipc	a0,0x4
    3202:	10a50513          	addi	a0,a0,266 # 7308 <malloc+0x17f2>
    3206:	00002097          	auipc	ra,0x2
    320a:	51a080e7          	jalr	1306(ra) # 5720 <open>
    320e:	84aa                	mv	s1,a0
  if(fd < 0){
    3210:	38054463          	bltz	a0,3598 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    3214:	660d                	lui	a2,0x3
    3216:	00009597          	auipc	a1,0x9
    321a:	9ba58593          	addi	a1,a1,-1606 # bbd0 <buf>
    321e:	00002097          	auipc	ra,0x2
    3222:	4da080e7          	jalr	1242(ra) # 56f8 <read>
    3226:	4789                	li	a5,2
    3228:	38f51663          	bne	a0,a5,35b4 <subdir+0x55e>
  close(fd);
    322c:	8526                	mv	a0,s1
    322e:	00002097          	auipc	ra,0x2
    3232:	4da080e7          	jalr	1242(ra) # 5708 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3236:	4581                	li	a1,0
    3238:	00004517          	auipc	a0,0x4
    323c:	04850513          	addi	a0,a0,72 # 7280 <malloc+0x176a>
    3240:	00002097          	auipc	ra,0x2
    3244:	4e0080e7          	jalr	1248(ra) # 5720 <open>
    3248:	38055463          	bgez	a0,35d0 <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    324c:	20200593          	li	a1,514
    3250:	00004517          	auipc	a0,0x4
    3254:	24050513          	addi	a0,a0,576 # 7490 <malloc+0x197a>
    3258:	00002097          	auipc	ra,0x2
    325c:	4c8080e7          	jalr	1224(ra) # 5720 <open>
    3260:	38055663          	bgez	a0,35ec <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    3264:	20200593          	li	a1,514
    3268:	00004517          	auipc	a0,0x4
    326c:	25850513          	addi	a0,a0,600 # 74c0 <malloc+0x19aa>
    3270:	00002097          	auipc	ra,0x2
    3274:	4b0080e7          	jalr	1200(ra) # 5720 <open>
    3278:	38055863          	bgez	a0,3608 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    327c:	20000593          	li	a1,512
    3280:	00004517          	auipc	a0,0x4
    3284:	f6050513          	addi	a0,a0,-160 # 71e0 <malloc+0x16ca>
    3288:	00002097          	auipc	ra,0x2
    328c:	498080e7          	jalr	1176(ra) # 5720 <open>
    3290:	38055a63          	bgez	a0,3624 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    3294:	4589                	li	a1,2
    3296:	00004517          	auipc	a0,0x4
    329a:	f4a50513          	addi	a0,a0,-182 # 71e0 <malloc+0x16ca>
    329e:	00002097          	auipc	ra,0x2
    32a2:	482080e7          	jalr	1154(ra) # 5720 <open>
    32a6:	38055d63          	bgez	a0,3640 <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    32aa:	4585                	li	a1,1
    32ac:	00004517          	auipc	a0,0x4
    32b0:	f3450513          	addi	a0,a0,-204 # 71e0 <malloc+0x16ca>
    32b4:	00002097          	auipc	ra,0x2
    32b8:	46c080e7          	jalr	1132(ra) # 5720 <open>
    32bc:	3a055063          	bgez	a0,365c <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    32c0:	00004597          	auipc	a1,0x4
    32c4:	29058593          	addi	a1,a1,656 # 7550 <malloc+0x1a3a>
    32c8:	00004517          	auipc	a0,0x4
    32cc:	1c850513          	addi	a0,a0,456 # 7490 <malloc+0x197a>
    32d0:	00002097          	auipc	ra,0x2
    32d4:	470080e7          	jalr	1136(ra) # 5740 <link>
    32d8:	3a050063          	beqz	a0,3678 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    32dc:	00004597          	auipc	a1,0x4
    32e0:	27458593          	addi	a1,a1,628 # 7550 <malloc+0x1a3a>
    32e4:	00004517          	auipc	a0,0x4
    32e8:	1dc50513          	addi	a0,a0,476 # 74c0 <malloc+0x19aa>
    32ec:	00002097          	auipc	ra,0x2
    32f0:	454080e7          	jalr	1108(ra) # 5740 <link>
    32f4:	3a050063          	beqz	a0,3694 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    32f8:	00004597          	auipc	a1,0x4
    32fc:	01058593          	addi	a1,a1,16 # 7308 <malloc+0x17f2>
    3300:	00004517          	auipc	a0,0x4
    3304:	f0050513          	addi	a0,a0,-256 # 7200 <malloc+0x16ea>
    3308:	00002097          	auipc	ra,0x2
    330c:	438080e7          	jalr	1080(ra) # 5740 <link>
    3310:	3a050063          	beqz	a0,36b0 <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    3314:	00004517          	auipc	a0,0x4
    3318:	17c50513          	addi	a0,a0,380 # 7490 <malloc+0x197a>
    331c:	00002097          	auipc	ra,0x2
    3320:	42c080e7          	jalr	1068(ra) # 5748 <mkdir>
    3324:	3a050463          	beqz	a0,36cc <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    3328:	00004517          	auipc	a0,0x4
    332c:	19850513          	addi	a0,a0,408 # 74c0 <malloc+0x19aa>
    3330:	00002097          	auipc	ra,0x2
    3334:	418080e7          	jalr	1048(ra) # 5748 <mkdir>
    3338:	3a050863          	beqz	a0,36e8 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    333c:	00004517          	auipc	a0,0x4
    3340:	fcc50513          	addi	a0,a0,-52 # 7308 <malloc+0x17f2>
    3344:	00002097          	auipc	ra,0x2
    3348:	404080e7          	jalr	1028(ra) # 5748 <mkdir>
    334c:	3a050c63          	beqz	a0,3704 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    3350:	00004517          	auipc	a0,0x4
    3354:	17050513          	addi	a0,a0,368 # 74c0 <malloc+0x19aa>
    3358:	00002097          	auipc	ra,0x2
    335c:	3d8080e7          	jalr	984(ra) # 5730 <unlink>
    3360:	3c050063          	beqz	a0,3720 <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    3364:	00004517          	auipc	a0,0x4
    3368:	12c50513          	addi	a0,a0,300 # 7490 <malloc+0x197a>
    336c:	00002097          	auipc	ra,0x2
    3370:	3c4080e7          	jalr	964(ra) # 5730 <unlink>
    3374:	3c050463          	beqz	a0,373c <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    3378:	00004517          	auipc	a0,0x4
    337c:	e8850513          	addi	a0,a0,-376 # 7200 <malloc+0x16ea>
    3380:	00002097          	auipc	ra,0x2
    3384:	3d0080e7          	jalr	976(ra) # 5750 <chdir>
    3388:	3c050863          	beqz	a0,3758 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    338c:	00004517          	auipc	a0,0x4
    3390:	31450513          	addi	a0,a0,788 # 76a0 <malloc+0x1b8a>
    3394:	00002097          	auipc	ra,0x2
    3398:	3bc080e7          	jalr	956(ra) # 5750 <chdir>
    339c:	3c050c63          	beqz	a0,3774 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    33a0:	00004517          	auipc	a0,0x4
    33a4:	f6850513          	addi	a0,a0,-152 # 7308 <malloc+0x17f2>
    33a8:	00002097          	auipc	ra,0x2
    33ac:	388080e7          	jalr	904(ra) # 5730 <unlink>
    33b0:	3e051063          	bnez	a0,3790 <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    33b4:	00004517          	auipc	a0,0x4
    33b8:	e4c50513          	addi	a0,a0,-436 # 7200 <malloc+0x16ea>
    33bc:	00002097          	auipc	ra,0x2
    33c0:	374080e7          	jalr	884(ra) # 5730 <unlink>
    33c4:	3e051463          	bnez	a0,37ac <subdir+0x756>
  if(unlink("dd") == 0){
    33c8:	00004517          	auipc	a0,0x4
    33cc:	e1850513          	addi	a0,a0,-488 # 71e0 <malloc+0x16ca>
    33d0:	00002097          	auipc	ra,0x2
    33d4:	360080e7          	jalr	864(ra) # 5730 <unlink>
    33d8:	3e050863          	beqz	a0,37c8 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    33dc:	00004517          	auipc	a0,0x4
    33e0:	33450513          	addi	a0,a0,820 # 7710 <malloc+0x1bfa>
    33e4:	00002097          	auipc	ra,0x2
    33e8:	34c080e7          	jalr	844(ra) # 5730 <unlink>
    33ec:	3e054c63          	bltz	a0,37e4 <subdir+0x78e>
  if(unlink("dd") < 0){
    33f0:	00004517          	auipc	a0,0x4
    33f4:	df050513          	addi	a0,a0,-528 # 71e0 <malloc+0x16ca>
    33f8:	00002097          	auipc	ra,0x2
    33fc:	338080e7          	jalr	824(ra) # 5730 <unlink>
    3400:	40054063          	bltz	a0,3800 <subdir+0x7aa>
}
    3404:	60e2                	ld	ra,24(sp)
    3406:	6442                	ld	s0,16(sp)
    3408:	64a2                	ld	s1,8(sp)
    340a:	6902                	ld	s2,0(sp)
    340c:	6105                	addi	sp,sp,32
    340e:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    3410:	85ca                	mv	a1,s2
    3412:	00004517          	auipc	a0,0x4
    3416:	dd650513          	addi	a0,a0,-554 # 71e8 <malloc+0x16d2>
    341a:	00002097          	auipc	ra,0x2
    341e:	63e080e7          	jalr	1598(ra) # 5a58 <printf>
    exit(1);
    3422:	4505                	li	a0,1
    3424:	00002097          	auipc	ra,0x2
    3428:	2bc080e7          	jalr	700(ra) # 56e0 <exit>
    printf("%s: create dd/ff failed\n", s);
    342c:	85ca                	mv	a1,s2
    342e:	00004517          	auipc	a0,0x4
    3432:	dda50513          	addi	a0,a0,-550 # 7208 <malloc+0x16f2>
    3436:	00002097          	auipc	ra,0x2
    343a:	622080e7          	jalr	1570(ra) # 5a58 <printf>
    exit(1);
    343e:	4505                	li	a0,1
    3440:	00002097          	auipc	ra,0x2
    3444:	2a0080e7          	jalr	672(ra) # 56e0 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3448:	85ca                	mv	a1,s2
    344a:	00004517          	auipc	a0,0x4
    344e:	dde50513          	addi	a0,a0,-546 # 7228 <malloc+0x1712>
    3452:	00002097          	auipc	ra,0x2
    3456:	606080e7          	jalr	1542(ra) # 5a58 <printf>
    exit(1);
    345a:	4505                	li	a0,1
    345c:	00002097          	auipc	ra,0x2
    3460:	284080e7          	jalr	644(ra) # 56e0 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3464:	85ca                	mv	a1,s2
    3466:	00004517          	auipc	a0,0x4
    346a:	dfa50513          	addi	a0,a0,-518 # 7260 <malloc+0x174a>
    346e:	00002097          	auipc	ra,0x2
    3472:	5ea080e7          	jalr	1514(ra) # 5a58 <printf>
    exit(1);
    3476:	4505                	li	a0,1
    3478:	00002097          	auipc	ra,0x2
    347c:	268080e7          	jalr	616(ra) # 56e0 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3480:	85ca                	mv	a1,s2
    3482:	00004517          	auipc	a0,0x4
    3486:	e0e50513          	addi	a0,a0,-498 # 7290 <malloc+0x177a>
    348a:	00002097          	auipc	ra,0x2
    348e:	5ce080e7          	jalr	1486(ra) # 5a58 <printf>
    exit(1);
    3492:	4505                	li	a0,1
    3494:	00002097          	auipc	ra,0x2
    3498:	24c080e7          	jalr	588(ra) # 56e0 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    349c:	85ca                	mv	a1,s2
    349e:	00004517          	auipc	a0,0x4
    34a2:	e2a50513          	addi	a0,a0,-470 # 72c8 <malloc+0x17b2>
    34a6:	00002097          	auipc	ra,0x2
    34aa:	5b2080e7          	jalr	1458(ra) # 5a58 <printf>
    exit(1);
    34ae:	4505                	li	a0,1
    34b0:	00002097          	auipc	ra,0x2
    34b4:	230080e7          	jalr	560(ra) # 56e0 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    34b8:	85ca                	mv	a1,s2
    34ba:	00004517          	auipc	a0,0x4
    34be:	e2e50513          	addi	a0,a0,-466 # 72e8 <malloc+0x17d2>
    34c2:	00002097          	auipc	ra,0x2
    34c6:	596080e7          	jalr	1430(ra) # 5a58 <printf>
    exit(1);
    34ca:	4505                	li	a0,1
    34cc:	00002097          	auipc	ra,0x2
    34d0:	214080e7          	jalr	532(ra) # 56e0 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    34d4:	85ca                	mv	a1,s2
    34d6:	00004517          	auipc	a0,0x4
    34da:	e4250513          	addi	a0,a0,-446 # 7318 <malloc+0x1802>
    34de:	00002097          	auipc	ra,0x2
    34e2:	57a080e7          	jalr	1402(ra) # 5a58 <printf>
    exit(1);
    34e6:	4505                	li	a0,1
    34e8:	00002097          	auipc	ra,0x2
    34ec:	1f8080e7          	jalr	504(ra) # 56e0 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    34f0:	85ca                	mv	a1,s2
    34f2:	00004517          	auipc	a0,0x4
    34f6:	e4e50513          	addi	a0,a0,-434 # 7340 <malloc+0x182a>
    34fa:	00002097          	auipc	ra,0x2
    34fe:	55e080e7          	jalr	1374(ra) # 5a58 <printf>
    exit(1);
    3502:	4505                	li	a0,1
    3504:	00002097          	auipc	ra,0x2
    3508:	1dc080e7          	jalr	476(ra) # 56e0 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    350c:	85ca                	mv	a1,s2
    350e:	00004517          	auipc	a0,0x4
    3512:	e5250513          	addi	a0,a0,-430 # 7360 <malloc+0x184a>
    3516:	00002097          	auipc	ra,0x2
    351a:	542080e7          	jalr	1346(ra) # 5a58 <printf>
    exit(1);
    351e:	4505                	li	a0,1
    3520:	00002097          	auipc	ra,0x2
    3524:	1c0080e7          	jalr	448(ra) # 56e0 <exit>
    printf("%s: chdir dd failed\n", s);
    3528:	85ca                	mv	a1,s2
    352a:	00004517          	auipc	a0,0x4
    352e:	e5e50513          	addi	a0,a0,-418 # 7388 <malloc+0x1872>
    3532:	00002097          	auipc	ra,0x2
    3536:	526080e7          	jalr	1318(ra) # 5a58 <printf>
    exit(1);
    353a:	4505                	li	a0,1
    353c:	00002097          	auipc	ra,0x2
    3540:	1a4080e7          	jalr	420(ra) # 56e0 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3544:	85ca                	mv	a1,s2
    3546:	00004517          	auipc	a0,0x4
    354a:	e6a50513          	addi	a0,a0,-406 # 73b0 <malloc+0x189a>
    354e:	00002097          	auipc	ra,0x2
    3552:	50a080e7          	jalr	1290(ra) # 5a58 <printf>
    exit(1);
    3556:	4505                	li	a0,1
    3558:	00002097          	auipc	ra,0x2
    355c:	188080e7          	jalr	392(ra) # 56e0 <exit>
    printf("chdir dd/../../dd failed\n", s);
    3560:	85ca                	mv	a1,s2
    3562:	00004517          	auipc	a0,0x4
    3566:	e7e50513          	addi	a0,a0,-386 # 73e0 <malloc+0x18ca>
    356a:	00002097          	auipc	ra,0x2
    356e:	4ee080e7          	jalr	1262(ra) # 5a58 <printf>
    exit(1);
    3572:	4505                	li	a0,1
    3574:	00002097          	auipc	ra,0x2
    3578:	16c080e7          	jalr	364(ra) # 56e0 <exit>
    printf("%s: chdir ./.. failed\n", s);
    357c:	85ca                	mv	a1,s2
    357e:	00004517          	auipc	a0,0x4
    3582:	e8a50513          	addi	a0,a0,-374 # 7408 <malloc+0x18f2>
    3586:	00002097          	auipc	ra,0x2
    358a:	4d2080e7          	jalr	1234(ra) # 5a58 <printf>
    exit(1);
    358e:	4505                	li	a0,1
    3590:	00002097          	auipc	ra,0x2
    3594:	150080e7          	jalr	336(ra) # 56e0 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3598:	85ca                	mv	a1,s2
    359a:	00004517          	auipc	a0,0x4
    359e:	e8650513          	addi	a0,a0,-378 # 7420 <malloc+0x190a>
    35a2:	00002097          	auipc	ra,0x2
    35a6:	4b6080e7          	jalr	1206(ra) # 5a58 <printf>
    exit(1);
    35aa:	4505                	li	a0,1
    35ac:	00002097          	auipc	ra,0x2
    35b0:	134080e7          	jalr	308(ra) # 56e0 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    35b4:	85ca                	mv	a1,s2
    35b6:	00004517          	auipc	a0,0x4
    35ba:	e8a50513          	addi	a0,a0,-374 # 7440 <malloc+0x192a>
    35be:	00002097          	auipc	ra,0x2
    35c2:	49a080e7          	jalr	1178(ra) # 5a58 <printf>
    exit(1);
    35c6:	4505                	li	a0,1
    35c8:	00002097          	auipc	ra,0x2
    35cc:	118080e7          	jalr	280(ra) # 56e0 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    35d0:	85ca                	mv	a1,s2
    35d2:	00004517          	auipc	a0,0x4
    35d6:	e8e50513          	addi	a0,a0,-370 # 7460 <malloc+0x194a>
    35da:	00002097          	auipc	ra,0x2
    35de:	47e080e7          	jalr	1150(ra) # 5a58 <printf>
    exit(1);
    35e2:	4505                	li	a0,1
    35e4:	00002097          	auipc	ra,0x2
    35e8:	0fc080e7          	jalr	252(ra) # 56e0 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    35ec:	85ca                	mv	a1,s2
    35ee:	00004517          	auipc	a0,0x4
    35f2:	eb250513          	addi	a0,a0,-334 # 74a0 <malloc+0x198a>
    35f6:	00002097          	auipc	ra,0x2
    35fa:	462080e7          	jalr	1122(ra) # 5a58 <printf>
    exit(1);
    35fe:	4505                	li	a0,1
    3600:	00002097          	auipc	ra,0x2
    3604:	0e0080e7          	jalr	224(ra) # 56e0 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3608:	85ca                	mv	a1,s2
    360a:	00004517          	auipc	a0,0x4
    360e:	ec650513          	addi	a0,a0,-314 # 74d0 <malloc+0x19ba>
    3612:	00002097          	auipc	ra,0x2
    3616:	446080e7          	jalr	1094(ra) # 5a58 <printf>
    exit(1);
    361a:	4505                	li	a0,1
    361c:	00002097          	auipc	ra,0x2
    3620:	0c4080e7          	jalr	196(ra) # 56e0 <exit>
    printf("%s: create dd succeeded!\n", s);
    3624:	85ca                	mv	a1,s2
    3626:	00004517          	auipc	a0,0x4
    362a:	eca50513          	addi	a0,a0,-310 # 74f0 <malloc+0x19da>
    362e:	00002097          	auipc	ra,0x2
    3632:	42a080e7          	jalr	1066(ra) # 5a58 <printf>
    exit(1);
    3636:	4505                	li	a0,1
    3638:	00002097          	auipc	ra,0x2
    363c:	0a8080e7          	jalr	168(ra) # 56e0 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    3640:	85ca                	mv	a1,s2
    3642:	00004517          	auipc	a0,0x4
    3646:	ece50513          	addi	a0,a0,-306 # 7510 <malloc+0x19fa>
    364a:	00002097          	auipc	ra,0x2
    364e:	40e080e7          	jalr	1038(ra) # 5a58 <printf>
    exit(1);
    3652:	4505                	li	a0,1
    3654:	00002097          	auipc	ra,0x2
    3658:	08c080e7          	jalr	140(ra) # 56e0 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    365c:	85ca                	mv	a1,s2
    365e:	00004517          	auipc	a0,0x4
    3662:	ed250513          	addi	a0,a0,-302 # 7530 <malloc+0x1a1a>
    3666:	00002097          	auipc	ra,0x2
    366a:	3f2080e7          	jalr	1010(ra) # 5a58 <printf>
    exit(1);
    366e:	4505                	li	a0,1
    3670:	00002097          	auipc	ra,0x2
    3674:	070080e7          	jalr	112(ra) # 56e0 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3678:	85ca                	mv	a1,s2
    367a:	00004517          	auipc	a0,0x4
    367e:	ee650513          	addi	a0,a0,-282 # 7560 <malloc+0x1a4a>
    3682:	00002097          	auipc	ra,0x2
    3686:	3d6080e7          	jalr	982(ra) # 5a58 <printf>
    exit(1);
    368a:	4505                	li	a0,1
    368c:	00002097          	auipc	ra,0x2
    3690:	054080e7          	jalr	84(ra) # 56e0 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3694:	85ca                	mv	a1,s2
    3696:	00004517          	auipc	a0,0x4
    369a:	ef250513          	addi	a0,a0,-270 # 7588 <malloc+0x1a72>
    369e:	00002097          	auipc	ra,0x2
    36a2:	3ba080e7          	jalr	954(ra) # 5a58 <printf>
    exit(1);
    36a6:	4505                	li	a0,1
    36a8:	00002097          	auipc	ra,0x2
    36ac:	038080e7          	jalr	56(ra) # 56e0 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    36b0:	85ca                	mv	a1,s2
    36b2:	00004517          	auipc	a0,0x4
    36b6:	efe50513          	addi	a0,a0,-258 # 75b0 <malloc+0x1a9a>
    36ba:	00002097          	auipc	ra,0x2
    36be:	39e080e7          	jalr	926(ra) # 5a58 <printf>
    exit(1);
    36c2:	4505                	li	a0,1
    36c4:	00002097          	auipc	ra,0x2
    36c8:	01c080e7          	jalr	28(ra) # 56e0 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    36cc:	85ca                	mv	a1,s2
    36ce:	00004517          	auipc	a0,0x4
    36d2:	f0a50513          	addi	a0,a0,-246 # 75d8 <malloc+0x1ac2>
    36d6:	00002097          	auipc	ra,0x2
    36da:	382080e7          	jalr	898(ra) # 5a58 <printf>
    exit(1);
    36de:	4505                	li	a0,1
    36e0:	00002097          	auipc	ra,0x2
    36e4:	000080e7          	jalr	ra # 56e0 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    36e8:	85ca                	mv	a1,s2
    36ea:	00004517          	auipc	a0,0x4
    36ee:	f0e50513          	addi	a0,a0,-242 # 75f8 <malloc+0x1ae2>
    36f2:	00002097          	auipc	ra,0x2
    36f6:	366080e7          	jalr	870(ra) # 5a58 <printf>
    exit(1);
    36fa:	4505                	li	a0,1
    36fc:	00002097          	auipc	ra,0x2
    3700:	fe4080e7          	jalr	-28(ra) # 56e0 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3704:	85ca                	mv	a1,s2
    3706:	00004517          	auipc	a0,0x4
    370a:	f1250513          	addi	a0,a0,-238 # 7618 <malloc+0x1b02>
    370e:	00002097          	auipc	ra,0x2
    3712:	34a080e7          	jalr	842(ra) # 5a58 <printf>
    exit(1);
    3716:	4505                	li	a0,1
    3718:	00002097          	auipc	ra,0x2
    371c:	fc8080e7          	jalr	-56(ra) # 56e0 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    3720:	85ca                	mv	a1,s2
    3722:	00004517          	auipc	a0,0x4
    3726:	f1e50513          	addi	a0,a0,-226 # 7640 <malloc+0x1b2a>
    372a:	00002097          	auipc	ra,0x2
    372e:	32e080e7          	jalr	814(ra) # 5a58 <printf>
    exit(1);
    3732:	4505                	li	a0,1
    3734:	00002097          	auipc	ra,0x2
    3738:	fac080e7          	jalr	-84(ra) # 56e0 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    373c:	85ca                	mv	a1,s2
    373e:	00004517          	auipc	a0,0x4
    3742:	f2250513          	addi	a0,a0,-222 # 7660 <malloc+0x1b4a>
    3746:	00002097          	auipc	ra,0x2
    374a:	312080e7          	jalr	786(ra) # 5a58 <printf>
    exit(1);
    374e:	4505                	li	a0,1
    3750:	00002097          	auipc	ra,0x2
    3754:	f90080e7          	jalr	-112(ra) # 56e0 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3758:	85ca                	mv	a1,s2
    375a:	00004517          	auipc	a0,0x4
    375e:	f2650513          	addi	a0,a0,-218 # 7680 <malloc+0x1b6a>
    3762:	00002097          	auipc	ra,0x2
    3766:	2f6080e7          	jalr	758(ra) # 5a58 <printf>
    exit(1);
    376a:	4505                	li	a0,1
    376c:	00002097          	auipc	ra,0x2
    3770:	f74080e7          	jalr	-140(ra) # 56e0 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3774:	85ca                	mv	a1,s2
    3776:	00004517          	auipc	a0,0x4
    377a:	f3250513          	addi	a0,a0,-206 # 76a8 <malloc+0x1b92>
    377e:	00002097          	auipc	ra,0x2
    3782:	2da080e7          	jalr	730(ra) # 5a58 <printf>
    exit(1);
    3786:	4505                	li	a0,1
    3788:	00002097          	auipc	ra,0x2
    378c:	f58080e7          	jalr	-168(ra) # 56e0 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3790:	85ca                	mv	a1,s2
    3792:	00004517          	auipc	a0,0x4
    3796:	bae50513          	addi	a0,a0,-1106 # 7340 <malloc+0x182a>
    379a:	00002097          	auipc	ra,0x2
    379e:	2be080e7          	jalr	702(ra) # 5a58 <printf>
    exit(1);
    37a2:	4505                	li	a0,1
    37a4:	00002097          	auipc	ra,0x2
    37a8:	f3c080e7          	jalr	-196(ra) # 56e0 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    37ac:	85ca                	mv	a1,s2
    37ae:	00004517          	auipc	a0,0x4
    37b2:	f1a50513          	addi	a0,a0,-230 # 76c8 <malloc+0x1bb2>
    37b6:	00002097          	auipc	ra,0x2
    37ba:	2a2080e7          	jalr	674(ra) # 5a58 <printf>
    exit(1);
    37be:	4505                	li	a0,1
    37c0:	00002097          	auipc	ra,0x2
    37c4:	f20080e7          	jalr	-224(ra) # 56e0 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    37c8:	85ca                	mv	a1,s2
    37ca:	00004517          	auipc	a0,0x4
    37ce:	f1e50513          	addi	a0,a0,-226 # 76e8 <malloc+0x1bd2>
    37d2:	00002097          	auipc	ra,0x2
    37d6:	286080e7          	jalr	646(ra) # 5a58 <printf>
    exit(1);
    37da:	4505                	li	a0,1
    37dc:	00002097          	auipc	ra,0x2
    37e0:	f04080e7          	jalr	-252(ra) # 56e0 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    37e4:	85ca                	mv	a1,s2
    37e6:	00004517          	auipc	a0,0x4
    37ea:	f3250513          	addi	a0,a0,-206 # 7718 <malloc+0x1c02>
    37ee:	00002097          	auipc	ra,0x2
    37f2:	26a080e7          	jalr	618(ra) # 5a58 <printf>
    exit(1);
    37f6:	4505                	li	a0,1
    37f8:	00002097          	auipc	ra,0x2
    37fc:	ee8080e7          	jalr	-280(ra) # 56e0 <exit>
    printf("%s: unlink dd failed\n", s);
    3800:	85ca                	mv	a1,s2
    3802:	00004517          	auipc	a0,0x4
    3806:	f3650513          	addi	a0,a0,-202 # 7738 <malloc+0x1c22>
    380a:	00002097          	auipc	ra,0x2
    380e:	24e080e7          	jalr	590(ra) # 5a58 <printf>
    exit(1);
    3812:	4505                	li	a0,1
    3814:	00002097          	auipc	ra,0x2
    3818:	ecc080e7          	jalr	-308(ra) # 56e0 <exit>

000000000000381c <rmdot>:
{
    381c:	1101                	addi	sp,sp,-32
    381e:	ec06                	sd	ra,24(sp)
    3820:	e822                	sd	s0,16(sp)
    3822:	e426                	sd	s1,8(sp)
    3824:	1000                	addi	s0,sp,32
    3826:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    3828:	00004517          	auipc	a0,0x4
    382c:	f2850513          	addi	a0,a0,-216 # 7750 <malloc+0x1c3a>
    3830:	00002097          	auipc	ra,0x2
    3834:	f18080e7          	jalr	-232(ra) # 5748 <mkdir>
    3838:	e549                	bnez	a0,38c2 <rmdot+0xa6>
  if(chdir("dots") != 0){
    383a:	00004517          	auipc	a0,0x4
    383e:	f1650513          	addi	a0,a0,-234 # 7750 <malloc+0x1c3a>
    3842:	00002097          	auipc	ra,0x2
    3846:	f0e080e7          	jalr	-242(ra) # 5750 <chdir>
    384a:	e951                	bnez	a0,38de <rmdot+0xc2>
  if(unlink(".") == 0){
    384c:	00003517          	auipc	a0,0x3
    3850:	db450513          	addi	a0,a0,-588 # 6600 <malloc+0xaea>
    3854:	00002097          	auipc	ra,0x2
    3858:	edc080e7          	jalr	-292(ra) # 5730 <unlink>
    385c:	cd59                	beqz	a0,38fa <rmdot+0xde>
  if(unlink("..") == 0){
    385e:	00004517          	auipc	a0,0x4
    3862:	94a50513          	addi	a0,a0,-1718 # 71a8 <malloc+0x1692>
    3866:	00002097          	auipc	ra,0x2
    386a:	eca080e7          	jalr	-310(ra) # 5730 <unlink>
    386e:	c545                	beqz	a0,3916 <rmdot+0xfa>
  if(chdir("/") != 0){
    3870:	00004517          	auipc	a0,0x4
    3874:	8e050513          	addi	a0,a0,-1824 # 7150 <malloc+0x163a>
    3878:	00002097          	auipc	ra,0x2
    387c:	ed8080e7          	jalr	-296(ra) # 5750 <chdir>
    3880:	e94d                	bnez	a0,3932 <rmdot+0x116>
  if(unlink("dots/.") == 0){
    3882:	00004517          	auipc	a0,0x4
    3886:	f3650513          	addi	a0,a0,-202 # 77b8 <malloc+0x1ca2>
    388a:	00002097          	auipc	ra,0x2
    388e:	ea6080e7          	jalr	-346(ra) # 5730 <unlink>
    3892:	cd55                	beqz	a0,394e <rmdot+0x132>
  if(unlink("dots/..") == 0){
    3894:	00004517          	auipc	a0,0x4
    3898:	f4c50513          	addi	a0,a0,-180 # 77e0 <malloc+0x1cca>
    389c:	00002097          	auipc	ra,0x2
    38a0:	e94080e7          	jalr	-364(ra) # 5730 <unlink>
    38a4:	c179                	beqz	a0,396a <rmdot+0x14e>
  if(unlink("dots") != 0){
    38a6:	00004517          	auipc	a0,0x4
    38aa:	eaa50513          	addi	a0,a0,-342 # 7750 <malloc+0x1c3a>
    38ae:	00002097          	auipc	ra,0x2
    38b2:	e82080e7          	jalr	-382(ra) # 5730 <unlink>
    38b6:	e961                	bnez	a0,3986 <rmdot+0x16a>
}
    38b8:	60e2                	ld	ra,24(sp)
    38ba:	6442                	ld	s0,16(sp)
    38bc:	64a2                	ld	s1,8(sp)
    38be:	6105                	addi	sp,sp,32
    38c0:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    38c2:	85a6                	mv	a1,s1
    38c4:	00004517          	auipc	a0,0x4
    38c8:	e9450513          	addi	a0,a0,-364 # 7758 <malloc+0x1c42>
    38cc:	00002097          	auipc	ra,0x2
    38d0:	18c080e7          	jalr	396(ra) # 5a58 <printf>
    exit(1);
    38d4:	4505                	li	a0,1
    38d6:	00002097          	auipc	ra,0x2
    38da:	e0a080e7          	jalr	-502(ra) # 56e0 <exit>
    printf("%s: chdir dots failed\n", s);
    38de:	85a6                	mv	a1,s1
    38e0:	00004517          	auipc	a0,0x4
    38e4:	e9050513          	addi	a0,a0,-368 # 7770 <malloc+0x1c5a>
    38e8:	00002097          	auipc	ra,0x2
    38ec:	170080e7          	jalr	368(ra) # 5a58 <printf>
    exit(1);
    38f0:	4505                	li	a0,1
    38f2:	00002097          	auipc	ra,0x2
    38f6:	dee080e7          	jalr	-530(ra) # 56e0 <exit>
    printf("%s: rm . worked!\n", s);
    38fa:	85a6                	mv	a1,s1
    38fc:	00004517          	auipc	a0,0x4
    3900:	e8c50513          	addi	a0,a0,-372 # 7788 <malloc+0x1c72>
    3904:	00002097          	auipc	ra,0x2
    3908:	154080e7          	jalr	340(ra) # 5a58 <printf>
    exit(1);
    390c:	4505                	li	a0,1
    390e:	00002097          	auipc	ra,0x2
    3912:	dd2080e7          	jalr	-558(ra) # 56e0 <exit>
    printf("%s: rm .. worked!\n", s);
    3916:	85a6                	mv	a1,s1
    3918:	00004517          	auipc	a0,0x4
    391c:	e8850513          	addi	a0,a0,-376 # 77a0 <malloc+0x1c8a>
    3920:	00002097          	auipc	ra,0x2
    3924:	138080e7          	jalr	312(ra) # 5a58 <printf>
    exit(1);
    3928:	4505                	li	a0,1
    392a:	00002097          	auipc	ra,0x2
    392e:	db6080e7          	jalr	-586(ra) # 56e0 <exit>
    printf("%s: chdir / failed\n", s);
    3932:	85a6                	mv	a1,s1
    3934:	00004517          	auipc	a0,0x4
    3938:	82450513          	addi	a0,a0,-2012 # 7158 <malloc+0x1642>
    393c:	00002097          	auipc	ra,0x2
    3940:	11c080e7          	jalr	284(ra) # 5a58 <printf>
    exit(1);
    3944:	4505                	li	a0,1
    3946:	00002097          	auipc	ra,0x2
    394a:	d9a080e7          	jalr	-614(ra) # 56e0 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    394e:	85a6                	mv	a1,s1
    3950:	00004517          	auipc	a0,0x4
    3954:	e7050513          	addi	a0,a0,-400 # 77c0 <malloc+0x1caa>
    3958:	00002097          	auipc	ra,0x2
    395c:	100080e7          	jalr	256(ra) # 5a58 <printf>
    exit(1);
    3960:	4505                	li	a0,1
    3962:	00002097          	auipc	ra,0x2
    3966:	d7e080e7          	jalr	-642(ra) # 56e0 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    396a:	85a6                	mv	a1,s1
    396c:	00004517          	auipc	a0,0x4
    3970:	e7c50513          	addi	a0,a0,-388 # 77e8 <malloc+0x1cd2>
    3974:	00002097          	auipc	ra,0x2
    3978:	0e4080e7          	jalr	228(ra) # 5a58 <printf>
    exit(1);
    397c:	4505                	li	a0,1
    397e:	00002097          	auipc	ra,0x2
    3982:	d62080e7          	jalr	-670(ra) # 56e0 <exit>
    printf("%s: unlink dots failed!\n", s);
    3986:	85a6                	mv	a1,s1
    3988:	00004517          	auipc	a0,0x4
    398c:	e8050513          	addi	a0,a0,-384 # 7808 <malloc+0x1cf2>
    3990:	00002097          	auipc	ra,0x2
    3994:	0c8080e7          	jalr	200(ra) # 5a58 <printf>
    exit(1);
    3998:	4505                	li	a0,1
    399a:	00002097          	auipc	ra,0x2
    399e:	d46080e7          	jalr	-698(ra) # 56e0 <exit>

00000000000039a2 <dirfile>:
{
    39a2:	1101                	addi	sp,sp,-32
    39a4:	ec06                	sd	ra,24(sp)
    39a6:	e822                	sd	s0,16(sp)
    39a8:	e426                	sd	s1,8(sp)
    39aa:	e04a                	sd	s2,0(sp)
    39ac:	1000                	addi	s0,sp,32
    39ae:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    39b0:	20000593          	li	a1,512
    39b4:	00002517          	auipc	a0,0x2
    39b8:	55450513          	addi	a0,a0,1364 # 5f08 <malloc+0x3f2>
    39bc:	00002097          	auipc	ra,0x2
    39c0:	d64080e7          	jalr	-668(ra) # 5720 <open>
  if(fd < 0){
    39c4:	0e054d63          	bltz	a0,3abe <dirfile+0x11c>
  close(fd);
    39c8:	00002097          	auipc	ra,0x2
    39cc:	d40080e7          	jalr	-704(ra) # 5708 <close>
  if(chdir("dirfile") == 0){
    39d0:	00002517          	auipc	a0,0x2
    39d4:	53850513          	addi	a0,a0,1336 # 5f08 <malloc+0x3f2>
    39d8:	00002097          	auipc	ra,0x2
    39dc:	d78080e7          	jalr	-648(ra) # 5750 <chdir>
    39e0:	cd6d                	beqz	a0,3ada <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    39e2:	4581                	li	a1,0
    39e4:	00004517          	auipc	a0,0x4
    39e8:	e8450513          	addi	a0,a0,-380 # 7868 <malloc+0x1d52>
    39ec:	00002097          	auipc	ra,0x2
    39f0:	d34080e7          	jalr	-716(ra) # 5720 <open>
  if(fd >= 0){
    39f4:	10055163          	bgez	a0,3af6 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    39f8:	20000593          	li	a1,512
    39fc:	00004517          	auipc	a0,0x4
    3a00:	e6c50513          	addi	a0,a0,-404 # 7868 <malloc+0x1d52>
    3a04:	00002097          	auipc	ra,0x2
    3a08:	d1c080e7          	jalr	-740(ra) # 5720 <open>
  if(fd >= 0){
    3a0c:	10055363          	bgez	a0,3b12 <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    3a10:	00004517          	auipc	a0,0x4
    3a14:	e5850513          	addi	a0,a0,-424 # 7868 <malloc+0x1d52>
    3a18:	00002097          	auipc	ra,0x2
    3a1c:	d30080e7          	jalr	-720(ra) # 5748 <mkdir>
    3a20:	10050763          	beqz	a0,3b2e <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    3a24:	00004517          	auipc	a0,0x4
    3a28:	e4450513          	addi	a0,a0,-444 # 7868 <malloc+0x1d52>
    3a2c:	00002097          	auipc	ra,0x2
    3a30:	d04080e7          	jalr	-764(ra) # 5730 <unlink>
    3a34:	10050b63          	beqz	a0,3b4a <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    3a38:	00004597          	auipc	a1,0x4
    3a3c:	e3058593          	addi	a1,a1,-464 # 7868 <malloc+0x1d52>
    3a40:	00002517          	auipc	a0,0x2
    3a44:	6c050513          	addi	a0,a0,1728 # 6100 <malloc+0x5ea>
    3a48:	00002097          	auipc	ra,0x2
    3a4c:	cf8080e7          	jalr	-776(ra) # 5740 <link>
    3a50:	10050b63          	beqz	a0,3b66 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    3a54:	00002517          	auipc	a0,0x2
    3a58:	4b450513          	addi	a0,a0,1204 # 5f08 <malloc+0x3f2>
    3a5c:	00002097          	auipc	ra,0x2
    3a60:	cd4080e7          	jalr	-812(ra) # 5730 <unlink>
    3a64:	10051f63          	bnez	a0,3b82 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    3a68:	4589                	li	a1,2
    3a6a:	00003517          	auipc	a0,0x3
    3a6e:	b9650513          	addi	a0,a0,-1130 # 6600 <malloc+0xaea>
    3a72:	00002097          	auipc	ra,0x2
    3a76:	cae080e7          	jalr	-850(ra) # 5720 <open>
  if(fd >= 0){
    3a7a:	12055263          	bgez	a0,3b9e <dirfile+0x1fc>
  fd = open(".", 0);
    3a7e:	4581                	li	a1,0
    3a80:	00003517          	auipc	a0,0x3
    3a84:	b8050513          	addi	a0,a0,-1152 # 6600 <malloc+0xaea>
    3a88:	00002097          	auipc	ra,0x2
    3a8c:	c98080e7          	jalr	-872(ra) # 5720 <open>
    3a90:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    3a92:	4605                	li	a2,1
    3a94:	00002597          	auipc	a1,0x2
    3a98:	54458593          	addi	a1,a1,1348 # 5fd8 <malloc+0x4c2>
    3a9c:	00002097          	auipc	ra,0x2
    3aa0:	c64080e7          	jalr	-924(ra) # 5700 <write>
    3aa4:	10a04b63          	bgtz	a0,3bba <dirfile+0x218>
  close(fd);
    3aa8:	8526                	mv	a0,s1
    3aaa:	00002097          	auipc	ra,0x2
    3aae:	c5e080e7          	jalr	-930(ra) # 5708 <close>
}
    3ab2:	60e2                	ld	ra,24(sp)
    3ab4:	6442                	ld	s0,16(sp)
    3ab6:	64a2                	ld	s1,8(sp)
    3ab8:	6902                	ld	s2,0(sp)
    3aba:	6105                	addi	sp,sp,32
    3abc:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    3abe:	85ca                	mv	a1,s2
    3ac0:	00004517          	auipc	a0,0x4
    3ac4:	d6850513          	addi	a0,a0,-664 # 7828 <malloc+0x1d12>
    3ac8:	00002097          	auipc	ra,0x2
    3acc:	f90080e7          	jalr	-112(ra) # 5a58 <printf>
    exit(1);
    3ad0:	4505                	li	a0,1
    3ad2:	00002097          	auipc	ra,0x2
    3ad6:	c0e080e7          	jalr	-1010(ra) # 56e0 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    3ada:	85ca                	mv	a1,s2
    3adc:	00004517          	auipc	a0,0x4
    3ae0:	d6c50513          	addi	a0,a0,-660 # 7848 <malloc+0x1d32>
    3ae4:	00002097          	auipc	ra,0x2
    3ae8:	f74080e7          	jalr	-140(ra) # 5a58 <printf>
    exit(1);
    3aec:	4505                	li	a0,1
    3aee:	00002097          	auipc	ra,0x2
    3af2:	bf2080e7          	jalr	-1038(ra) # 56e0 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3af6:	85ca                	mv	a1,s2
    3af8:	00004517          	auipc	a0,0x4
    3afc:	d8050513          	addi	a0,a0,-640 # 7878 <malloc+0x1d62>
    3b00:	00002097          	auipc	ra,0x2
    3b04:	f58080e7          	jalr	-168(ra) # 5a58 <printf>
    exit(1);
    3b08:	4505                	li	a0,1
    3b0a:	00002097          	auipc	ra,0x2
    3b0e:	bd6080e7          	jalr	-1066(ra) # 56e0 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3b12:	85ca                	mv	a1,s2
    3b14:	00004517          	auipc	a0,0x4
    3b18:	d6450513          	addi	a0,a0,-668 # 7878 <malloc+0x1d62>
    3b1c:	00002097          	auipc	ra,0x2
    3b20:	f3c080e7          	jalr	-196(ra) # 5a58 <printf>
    exit(1);
    3b24:	4505                	li	a0,1
    3b26:	00002097          	auipc	ra,0x2
    3b2a:	bba080e7          	jalr	-1094(ra) # 56e0 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    3b2e:	85ca                	mv	a1,s2
    3b30:	00004517          	auipc	a0,0x4
    3b34:	d7050513          	addi	a0,a0,-656 # 78a0 <malloc+0x1d8a>
    3b38:	00002097          	auipc	ra,0x2
    3b3c:	f20080e7          	jalr	-224(ra) # 5a58 <printf>
    exit(1);
    3b40:	4505                	li	a0,1
    3b42:	00002097          	auipc	ra,0x2
    3b46:	b9e080e7          	jalr	-1122(ra) # 56e0 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    3b4a:	85ca                	mv	a1,s2
    3b4c:	00004517          	auipc	a0,0x4
    3b50:	d7c50513          	addi	a0,a0,-644 # 78c8 <malloc+0x1db2>
    3b54:	00002097          	auipc	ra,0x2
    3b58:	f04080e7          	jalr	-252(ra) # 5a58 <printf>
    exit(1);
    3b5c:	4505                	li	a0,1
    3b5e:	00002097          	auipc	ra,0x2
    3b62:	b82080e7          	jalr	-1150(ra) # 56e0 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3b66:	85ca                	mv	a1,s2
    3b68:	00004517          	auipc	a0,0x4
    3b6c:	d8850513          	addi	a0,a0,-632 # 78f0 <malloc+0x1dda>
    3b70:	00002097          	auipc	ra,0x2
    3b74:	ee8080e7          	jalr	-280(ra) # 5a58 <printf>
    exit(1);
    3b78:	4505                	li	a0,1
    3b7a:	00002097          	auipc	ra,0x2
    3b7e:	b66080e7          	jalr	-1178(ra) # 56e0 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    3b82:	85ca                	mv	a1,s2
    3b84:	00004517          	auipc	a0,0x4
    3b88:	d9450513          	addi	a0,a0,-620 # 7918 <malloc+0x1e02>
    3b8c:	00002097          	auipc	ra,0x2
    3b90:	ecc080e7          	jalr	-308(ra) # 5a58 <printf>
    exit(1);
    3b94:	4505                	li	a0,1
    3b96:	00002097          	auipc	ra,0x2
    3b9a:	b4a080e7          	jalr	-1206(ra) # 56e0 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    3b9e:	85ca                	mv	a1,s2
    3ba0:	00004517          	auipc	a0,0x4
    3ba4:	d9850513          	addi	a0,a0,-616 # 7938 <malloc+0x1e22>
    3ba8:	00002097          	auipc	ra,0x2
    3bac:	eb0080e7          	jalr	-336(ra) # 5a58 <printf>
    exit(1);
    3bb0:	4505                	li	a0,1
    3bb2:	00002097          	auipc	ra,0x2
    3bb6:	b2e080e7          	jalr	-1234(ra) # 56e0 <exit>
    printf("%s: write . succeeded!\n", s);
    3bba:	85ca                	mv	a1,s2
    3bbc:	00004517          	auipc	a0,0x4
    3bc0:	da450513          	addi	a0,a0,-604 # 7960 <malloc+0x1e4a>
    3bc4:	00002097          	auipc	ra,0x2
    3bc8:	e94080e7          	jalr	-364(ra) # 5a58 <printf>
    exit(1);
    3bcc:	4505                	li	a0,1
    3bce:	00002097          	auipc	ra,0x2
    3bd2:	b12080e7          	jalr	-1262(ra) # 56e0 <exit>

0000000000003bd6 <iref>:
{
    3bd6:	7139                	addi	sp,sp,-64
    3bd8:	fc06                	sd	ra,56(sp)
    3bda:	f822                	sd	s0,48(sp)
    3bdc:	f426                	sd	s1,40(sp)
    3bde:	f04a                	sd	s2,32(sp)
    3be0:	ec4e                	sd	s3,24(sp)
    3be2:	e852                	sd	s4,16(sp)
    3be4:	e456                	sd	s5,8(sp)
    3be6:	e05a                	sd	s6,0(sp)
    3be8:	0080                	addi	s0,sp,64
    3bea:	8b2a                	mv	s6,a0
    3bec:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    3bf0:	00004a17          	auipc	s4,0x4
    3bf4:	d88a0a13          	addi	s4,s4,-632 # 7978 <malloc+0x1e62>
    mkdir("");
    3bf8:	00004497          	auipc	s1,0x4
    3bfc:	89048493          	addi	s1,s1,-1904 # 7488 <malloc+0x1972>
    link("README", "");
    3c00:	00002a97          	auipc	s5,0x2
    3c04:	500a8a93          	addi	s5,s5,1280 # 6100 <malloc+0x5ea>
    fd = open("xx", O_CREATE);
    3c08:	00004997          	auipc	s3,0x4
    3c0c:	c6898993          	addi	s3,s3,-920 # 7870 <malloc+0x1d5a>
    3c10:	a891                	j	3c64 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    3c12:	85da                	mv	a1,s6
    3c14:	00004517          	auipc	a0,0x4
    3c18:	d6c50513          	addi	a0,a0,-660 # 7980 <malloc+0x1e6a>
    3c1c:	00002097          	auipc	ra,0x2
    3c20:	e3c080e7          	jalr	-452(ra) # 5a58 <printf>
      exit(1);
    3c24:	4505                	li	a0,1
    3c26:	00002097          	auipc	ra,0x2
    3c2a:	aba080e7          	jalr	-1350(ra) # 56e0 <exit>
      printf("%s: chdir irefd failed\n", s);
    3c2e:	85da                	mv	a1,s6
    3c30:	00004517          	auipc	a0,0x4
    3c34:	d6850513          	addi	a0,a0,-664 # 7998 <malloc+0x1e82>
    3c38:	00002097          	auipc	ra,0x2
    3c3c:	e20080e7          	jalr	-480(ra) # 5a58 <printf>
      exit(1);
    3c40:	4505                	li	a0,1
    3c42:	00002097          	auipc	ra,0x2
    3c46:	a9e080e7          	jalr	-1378(ra) # 56e0 <exit>
      close(fd);
    3c4a:	00002097          	auipc	ra,0x2
    3c4e:	abe080e7          	jalr	-1346(ra) # 5708 <close>
    3c52:	a889                	j	3ca4 <iref+0xce>
    unlink("xx");
    3c54:	854e                	mv	a0,s3
    3c56:	00002097          	auipc	ra,0x2
    3c5a:	ada080e7          	jalr	-1318(ra) # 5730 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3c5e:	397d                	addiw	s2,s2,-1
    3c60:	06090063          	beqz	s2,3cc0 <iref+0xea>
    if(mkdir("irefd") != 0){
    3c64:	8552                	mv	a0,s4
    3c66:	00002097          	auipc	ra,0x2
    3c6a:	ae2080e7          	jalr	-1310(ra) # 5748 <mkdir>
    3c6e:	f155                	bnez	a0,3c12 <iref+0x3c>
    if(chdir("irefd") != 0){
    3c70:	8552                	mv	a0,s4
    3c72:	00002097          	auipc	ra,0x2
    3c76:	ade080e7          	jalr	-1314(ra) # 5750 <chdir>
    3c7a:	f955                	bnez	a0,3c2e <iref+0x58>
    mkdir("");
    3c7c:	8526                	mv	a0,s1
    3c7e:	00002097          	auipc	ra,0x2
    3c82:	aca080e7          	jalr	-1334(ra) # 5748 <mkdir>
    link("README", "");
    3c86:	85a6                	mv	a1,s1
    3c88:	8556                	mv	a0,s5
    3c8a:	00002097          	auipc	ra,0x2
    3c8e:	ab6080e7          	jalr	-1354(ra) # 5740 <link>
    fd = open("", O_CREATE);
    3c92:	20000593          	li	a1,512
    3c96:	8526                	mv	a0,s1
    3c98:	00002097          	auipc	ra,0x2
    3c9c:	a88080e7          	jalr	-1400(ra) # 5720 <open>
    if(fd >= 0)
    3ca0:	fa0555e3          	bgez	a0,3c4a <iref+0x74>
    fd = open("xx", O_CREATE);
    3ca4:	20000593          	li	a1,512
    3ca8:	854e                	mv	a0,s3
    3caa:	00002097          	auipc	ra,0x2
    3cae:	a76080e7          	jalr	-1418(ra) # 5720 <open>
    if(fd >= 0)
    3cb2:	fa0541e3          	bltz	a0,3c54 <iref+0x7e>
      close(fd);
    3cb6:	00002097          	auipc	ra,0x2
    3cba:	a52080e7          	jalr	-1454(ra) # 5708 <close>
    3cbe:	bf59                	j	3c54 <iref+0x7e>
    3cc0:	03300493          	li	s1,51
    chdir("..");
    3cc4:	00003997          	auipc	s3,0x3
    3cc8:	4e498993          	addi	s3,s3,1252 # 71a8 <malloc+0x1692>
    unlink("irefd");
    3ccc:	00004917          	auipc	s2,0x4
    3cd0:	cac90913          	addi	s2,s2,-852 # 7978 <malloc+0x1e62>
    chdir("..");
    3cd4:	854e                	mv	a0,s3
    3cd6:	00002097          	auipc	ra,0x2
    3cda:	a7a080e7          	jalr	-1414(ra) # 5750 <chdir>
    unlink("irefd");
    3cde:	854a                	mv	a0,s2
    3ce0:	00002097          	auipc	ra,0x2
    3ce4:	a50080e7          	jalr	-1456(ra) # 5730 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3ce8:	34fd                	addiw	s1,s1,-1
    3cea:	f4ed                	bnez	s1,3cd4 <iref+0xfe>
  chdir("/");
    3cec:	00003517          	auipc	a0,0x3
    3cf0:	46450513          	addi	a0,a0,1124 # 7150 <malloc+0x163a>
    3cf4:	00002097          	auipc	ra,0x2
    3cf8:	a5c080e7          	jalr	-1444(ra) # 5750 <chdir>
}
    3cfc:	70e2                	ld	ra,56(sp)
    3cfe:	7442                	ld	s0,48(sp)
    3d00:	74a2                	ld	s1,40(sp)
    3d02:	7902                	ld	s2,32(sp)
    3d04:	69e2                	ld	s3,24(sp)
    3d06:	6a42                	ld	s4,16(sp)
    3d08:	6aa2                	ld	s5,8(sp)
    3d0a:	6b02                	ld	s6,0(sp)
    3d0c:	6121                	addi	sp,sp,64
    3d0e:	8082                	ret

0000000000003d10 <openiputtest>:
{
    3d10:	7179                	addi	sp,sp,-48
    3d12:	f406                	sd	ra,40(sp)
    3d14:	f022                	sd	s0,32(sp)
    3d16:	ec26                	sd	s1,24(sp)
    3d18:	1800                	addi	s0,sp,48
    3d1a:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    3d1c:	00004517          	auipc	a0,0x4
    3d20:	c9450513          	addi	a0,a0,-876 # 79b0 <malloc+0x1e9a>
    3d24:	00002097          	auipc	ra,0x2
    3d28:	a24080e7          	jalr	-1500(ra) # 5748 <mkdir>
    3d2c:	04054263          	bltz	a0,3d70 <openiputtest+0x60>
  pid = fork();
    3d30:	00002097          	auipc	ra,0x2
    3d34:	9a8080e7          	jalr	-1624(ra) # 56d8 <fork>
  if(pid < 0){
    3d38:	04054a63          	bltz	a0,3d8c <openiputtest+0x7c>
  if(pid == 0){
    3d3c:	e93d                	bnez	a0,3db2 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    3d3e:	4589                	li	a1,2
    3d40:	00004517          	auipc	a0,0x4
    3d44:	c7050513          	addi	a0,a0,-912 # 79b0 <malloc+0x1e9a>
    3d48:	00002097          	auipc	ra,0x2
    3d4c:	9d8080e7          	jalr	-1576(ra) # 5720 <open>
    if(fd >= 0){
    3d50:	04054c63          	bltz	a0,3da8 <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    3d54:	85a6                	mv	a1,s1
    3d56:	00004517          	auipc	a0,0x4
    3d5a:	c7a50513          	addi	a0,a0,-902 # 79d0 <malloc+0x1eba>
    3d5e:	00002097          	auipc	ra,0x2
    3d62:	cfa080e7          	jalr	-774(ra) # 5a58 <printf>
      exit(1);
    3d66:	4505                	li	a0,1
    3d68:	00002097          	auipc	ra,0x2
    3d6c:	978080e7          	jalr	-1672(ra) # 56e0 <exit>
    printf("%s: mkdir oidir failed\n", s);
    3d70:	85a6                	mv	a1,s1
    3d72:	00004517          	auipc	a0,0x4
    3d76:	c4650513          	addi	a0,a0,-954 # 79b8 <malloc+0x1ea2>
    3d7a:	00002097          	auipc	ra,0x2
    3d7e:	cde080e7          	jalr	-802(ra) # 5a58 <printf>
    exit(1);
    3d82:	4505                	li	a0,1
    3d84:	00002097          	auipc	ra,0x2
    3d88:	95c080e7          	jalr	-1700(ra) # 56e0 <exit>
    printf("%s: fork failed\n", s);
    3d8c:	85a6                	mv	a1,s1
    3d8e:	00003517          	auipc	a0,0x3
    3d92:	a1250513          	addi	a0,a0,-1518 # 67a0 <malloc+0xc8a>
    3d96:	00002097          	auipc	ra,0x2
    3d9a:	cc2080e7          	jalr	-830(ra) # 5a58 <printf>
    exit(1);
    3d9e:	4505                	li	a0,1
    3da0:	00002097          	auipc	ra,0x2
    3da4:	940080e7          	jalr	-1728(ra) # 56e0 <exit>
    exit(0);
    3da8:	4501                	li	a0,0
    3daa:	00002097          	auipc	ra,0x2
    3dae:	936080e7          	jalr	-1738(ra) # 56e0 <exit>
  sleep(1);
    3db2:	4505                	li	a0,1
    3db4:	00002097          	auipc	ra,0x2
    3db8:	9bc080e7          	jalr	-1604(ra) # 5770 <sleep>
  if(unlink("oidir") != 0){
    3dbc:	00004517          	auipc	a0,0x4
    3dc0:	bf450513          	addi	a0,a0,-1036 # 79b0 <malloc+0x1e9a>
    3dc4:	00002097          	auipc	ra,0x2
    3dc8:	96c080e7          	jalr	-1684(ra) # 5730 <unlink>
    3dcc:	cd19                	beqz	a0,3dea <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    3dce:	85a6                	mv	a1,s1
    3dd0:	00003517          	auipc	a0,0x3
    3dd4:	bc050513          	addi	a0,a0,-1088 # 6990 <malloc+0xe7a>
    3dd8:	00002097          	auipc	ra,0x2
    3ddc:	c80080e7          	jalr	-896(ra) # 5a58 <printf>
    exit(1);
    3de0:	4505                	li	a0,1
    3de2:	00002097          	auipc	ra,0x2
    3de6:	8fe080e7          	jalr	-1794(ra) # 56e0 <exit>
  wait(&xstatus);
    3dea:	fdc40513          	addi	a0,s0,-36
    3dee:	00002097          	auipc	ra,0x2
    3df2:	8fa080e7          	jalr	-1798(ra) # 56e8 <wait>
  exit(xstatus);
    3df6:	fdc42503          	lw	a0,-36(s0)
    3dfa:	00002097          	auipc	ra,0x2
    3dfe:	8e6080e7          	jalr	-1818(ra) # 56e0 <exit>

0000000000003e02 <forkforkfork>:
{
    3e02:	1101                	addi	sp,sp,-32
    3e04:	ec06                	sd	ra,24(sp)
    3e06:	e822                	sd	s0,16(sp)
    3e08:	e426                	sd	s1,8(sp)
    3e0a:	1000                	addi	s0,sp,32
    3e0c:	84aa                	mv	s1,a0
  unlink("stopforking");
    3e0e:	00004517          	auipc	a0,0x4
    3e12:	bea50513          	addi	a0,a0,-1046 # 79f8 <malloc+0x1ee2>
    3e16:	00002097          	auipc	ra,0x2
    3e1a:	91a080e7          	jalr	-1766(ra) # 5730 <unlink>
  int pid = fork();
    3e1e:	00002097          	auipc	ra,0x2
    3e22:	8ba080e7          	jalr	-1862(ra) # 56d8 <fork>
  if(pid < 0){
    3e26:	04054563          	bltz	a0,3e70 <forkforkfork+0x6e>
  if(pid == 0){
    3e2a:	c12d                	beqz	a0,3e8c <forkforkfork+0x8a>
  sleep(20); // two seconds
    3e2c:	4551                	li	a0,20
    3e2e:	00002097          	auipc	ra,0x2
    3e32:	942080e7          	jalr	-1726(ra) # 5770 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    3e36:	20200593          	li	a1,514
    3e3a:	00004517          	auipc	a0,0x4
    3e3e:	bbe50513          	addi	a0,a0,-1090 # 79f8 <malloc+0x1ee2>
    3e42:	00002097          	auipc	ra,0x2
    3e46:	8de080e7          	jalr	-1826(ra) # 5720 <open>
    3e4a:	00002097          	auipc	ra,0x2
    3e4e:	8be080e7          	jalr	-1858(ra) # 5708 <close>
  wait(0);
    3e52:	4501                	li	a0,0
    3e54:	00002097          	auipc	ra,0x2
    3e58:	894080e7          	jalr	-1900(ra) # 56e8 <wait>
  sleep(10); // one second
    3e5c:	4529                	li	a0,10
    3e5e:	00002097          	auipc	ra,0x2
    3e62:	912080e7          	jalr	-1774(ra) # 5770 <sleep>
}
    3e66:	60e2                	ld	ra,24(sp)
    3e68:	6442                	ld	s0,16(sp)
    3e6a:	64a2                	ld	s1,8(sp)
    3e6c:	6105                	addi	sp,sp,32
    3e6e:	8082                	ret
    printf("%s: fork failed", s);
    3e70:	85a6                	mv	a1,s1
    3e72:	00003517          	auipc	a0,0x3
    3e76:	aee50513          	addi	a0,a0,-1298 # 6960 <malloc+0xe4a>
    3e7a:	00002097          	auipc	ra,0x2
    3e7e:	bde080e7          	jalr	-1058(ra) # 5a58 <printf>
    exit(1);
    3e82:	4505                	li	a0,1
    3e84:	00002097          	auipc	ra,0x2
    3e88:	85c080e7          	jalr	-1956(ra) # 56e0 <exit>
      int fd = open("stopforking", 0);
    3e8c:	00004497          	auipc	s1,0x4
    3e90:	b6c48493          	addi	s1,s1,-1172 # 79f8 <malloc+0x1ee2>
    3e94:	4581                	li	a1,0
    3e96:	8526                	mv	a0,s1
    3e98:	00002097          	auipc	ra,0x2
    3e9c:	888080e7          	jalr	-1912(ra) # 5720 <open>
      if(fd >= 0){
    3ea0:	02055463          	bgez	a0,3ec8 <forkforkfork+0xc6>
      if(fork() < 0){
    3ea4:	00002097          	auipc	ra,0x2
    3ea8:	834080e7          	jalr	-1996(ra) # 56d8 <fork>
    3eac:	fe0554e3          	bgez	a0,3e94 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    3eb0:	20200593          	li	a1,514
    3eb4:	8526                	mv	a0,s1
    3eb6:	00002097          	auipc	ra,0x2
    3eba:	86a080e7          	jalr	-1942(ra) # 5720 <open>
    3ebe:	00002097          	auipc	ra,0x2
    3ec2:	84a080e7          	jalr	-1974(ra) # 5708 <close>
    3ec6:	b7f9                	j	3e94 <forkforkfork+0x92>
        exit(0);
    3ec8:	4501                	li	a0,0
    3eca:	00002097          	auipc	ra,0x2
    3ece:	816080e7          	jalr	-2026(ra) # 56e0 <exit>

0000000000003ed2 <killstatus>:
{
    3ed2:	7139                	addi	sp,sp,-64
    3ed4:	fc06                	sd	ra,56(sp)
    3ed6:	f822                	sd	s0,48(sp)
    3ed8:	f426                	sd	s1,40(sp)
    3eda:	f04a                	sd	s2,32(sp)
    3edc:	ec4e                	sd	s3,24(sp)
    3ede:	e852                	sd	s4,16(sp)
    3ee0:	0080                	addi	s0,sp,64
    3ee2:	8a2a                	mv	s4,a0
    3ee4:	06400913          	li	s2,100
    if(xst != -1) {
    3ee8:	59fd                	li	s3,-1
    int pid1 = fork();
    3eea:	00001097          	auipc	ra,0x1
    3eee:	7ee080e7          	jalr	2030(ra) # 56d8 <fork>
    3ef2:	84aa                	mv	s1,a0
    if(pid1 < 0){
    3ef4:	02054f63          	bltz	a0,3f32 <killstatus+0x60>
    if(pid1 == 0){
    3ef8:	c939                	beqz	a0,3f4e <killstatus+0x7c>
    sleep(1);
    3efa:	4505                	li	a0,1
    3efc:	00002097          	auipc	ra,0x2
    3f00:	874080e7          	jalr	-1932(ra) # 5770 <sleep>
    kill(pid1);
    3f04:	8526                	mv	a0,s1
    3f06:	00002097          	auipc	ra,0x2
    3f0a:	80a080e7          	jalr	-2038(ra) # 5710 <kill>
    wait(&xst);
    3f0e:	fcc40513          	addi	a0,s0,-52
    3f12:	00001097          	auipc	ra,0x1
    3f16:	7d6080e7          	jalr	2006(ra) # 56e8 <wait>
    if(xst != -1) {
    3f1a:	fcc42783          	lw	a5,-52(s0)
    3f1e:	03379d63          	bne	a5,s3,3f58 <killstatus+0x86>
  for(int i = 0; i < 100; i++){
    3f22:	397d                	addiw	s2,s2,-1
    3f24:	fc0913e3          	bnez	s2,3eea <killstatus+0x18>
  exit(0);
    3f28:	4501                	li	a0,0
    3f2a:	00001097          	auipc	ra,0x1
    3f2e:	7b6080e7          	jalr	1974(ra) # 56e0 <exit>
      printf("%s: fork failed\n", s);
    3f32:	85d2                	mv	a1,s4
    3f34:	00003517          	auipc	a0,0x3
    3f38:	86c50513          	addi	a0,a0,-1940 # 67a0 <malloc+0xc8a>
    3f3c:	00002097          	auipc	ra,0x2
    3f40:	b1c080e7          	jalr	-1252(ra) # 5a58 <printf>
      exit(1);
    3f44:	4505                	li	a0,1
    3f46:	00001097          	auipc	ra,0x1
    3f4a:	79a080e7          	jalr	1946(ra) # 56e0 <exit>
        getpid();
    3f4e:	00002097          	auipc	ra,0x2
    3f52:	812080e7          	jalr	-2030(ra) # 5760 <getpid>
      while(1) {
    3f56:	bfe5                	j	3f4e <killstatus+0x7c>
       printf("%s: status should be -1\n", s);
    3f58:	85d2                	mv	a1,s4
    3f5a:	00004517          	auipc	a0,0x4
    3f5e:	aae50513          	addi	a0,a0,-1362 # 7a08 <malloc+0x1ef2>
    3f62:	00002097          	auipc	ra,0x2
    3f66:	af6080e7          	jalr	-1290(ra) # 5a58 <printf>
       exit(1);
    3f6a:	4505                	li	a0,1
    3f6c:	00001097          	auipc	ra,0x1
    3f70:	774080e7          	jalr	1908(ra) # 56e0 <exit>

0000000000003f74 <preempt>:
{
    3f74:	7139                	addi	sp,sp,-64
    3f76:	fc06                	sd	ra,56(sp)
    3f78:	f822                	sd	s0,48(sp)
    3f7a:	f426                	sd	s1,40(sp)
    3f7c:	f04a                	sd	s2,32(sp)
    3f7e:	ec4e                	sd	s3,24(sp)
    3f80:	e852                	sd	s4,16(sp)
    3f82:	0080                	addi	s0,sp,64
    3f84:	892a                	mv	s2,a0
  pid1 = fork();
    3f86:	00001097          	auipc	ra,0x1
    3f8a:	752080e7          	jalr	1874(ra) # 56d8 <fork>
  if(pid1 < 0) {
    3f8e:	00054563          	bltz	a0,3f98 <preempt+0x24>
    3f92:	84aa                	mv	s1,a0
  if(pid1 == 0)
    3f94:	e105                	bnez	a0,3fb4 <preempt+0x40>
    for(;;)
    3f96:	a001                	j	3f96 <preempt+0x22>
    printf("%s: fork failed", s);
    3f98:	85ca                	mv	a1,s2
    3f9a:	00003517          	auipc	a0,0x3
    3f9e:	9c650513          	addi	a0,a0,-1594 # 6960 <malloc+0xe4a>
    3fa2:	00002097          	auipc	ra,0x2
    3fa6:	ab6080e7          	jalr	-1354(ra) # 5a58 <printf>
    exit(1);
    3faa:	4505                	li	a0,1
    3fac:	00001097          	auipc	ra,0x1
    3fb0:	734080e7          	jalr	1844(ra) # 56e0 <exit>
  pid2 = fork();
    3fb4:	00001097          	auipc	ra,0x1
    3fb8:	724080e7          	jalr	1828(ra) # 56d8 <fork>
    3fbc:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    3fbe:	00054463          	bltz	a0,3fc6 <preempt+0x52>
  if(pid2 == 0)
    3fc2:	e105                	bnez	a0,3fe2 <preempt+0x6e>
    for(;;)
    3fc4:	a001                	j	3fc4 <preempt+0x50>
    printf("%s: fork failed\n", s);
    3fc6:	85ca                	mv	a1,s2
    3fc8:	00002517          	auipc	a0,0x2
    3fcc:	7d850513          	addi	a0,a0,2008 # 67a0 <malloc+0xc8a>
    3fd0:	00002097          	auipc	ra,0x2
    3fd4:	a88080e7          	jalr	-1400(ra) # 5a58 <printf>
    exit(1);
    3fd8:	4505                	li	a0,1
    3fda:	00001097          	auipc	ra,0x1
    3fde:	706080e7          	jalr	1798(ra) # 56e0 <exit>
  pipe(pfds);
    3fe2:	fc840513          	addi	a0,s0,-56
    3fe6:	00001097          	auipc	ra,0x1
    3fea:	70a080e7          	jalr	1802(ra) # 56f0 <pipe>
  pid3 = fork();
    3fee:	00001097          	auipc	ra,0x1
    3ff2:	6ea080e7          	jalr	1770(ra) # 56d8 <fork>
    3ff6:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    3ff8:	02054e63          	bltz	a0,4034 <preempt+0xc0>
  if(pid3 == 0){
    3ffc:	e525                	bnez	a0,4064 <preempt+0xf0>
    close(pfds[0]);
    3ffe:	fc842503          	lw	a0,-56(s0)
    4002:	00001097          	auipc	ra,0x1
    4006:	706080e7          	jalr	1798(ra) # 5708 <close>
    if(write(pfds[1], "x", 1) != 1)
    400a:	4605                	li	a2,1
    400c:	00002597          	auipc	a1,0x2
    4010:	fcc58593          	addi	a1,a1,-52 # 5fd8 <malloc+0x4c2>
    4014:	fcc42503          	lw	a0,-52(s0)
    4018:	00001097          	auipc	ra,0x1
    401c:	6e8080e7          	jalr	1768(ra) # 5700 <write>
    4020:	4785                	li	a5,1
    4022:	02f51763          	bne	a0,a5,4050 <preempt+0xdc>
    close(pfds[1]);
    4026:	fcc42503          	lw	a0,-52(s0)
    402a:	00001097          	auipc	ra,0x1
    402e:	6de080e7          	jalr	1758(ra) # 5708 <close>
    for(;;)
    4032:	a001                	j	4032 <preempt+0xbe>
     printf("%s: fork failed\n", s);
    4034:	85ca                	mv	a1,s2
    4036:	00002517          	auipc	a0,0x2
    403a:	76a50513          	addi	a0,a0,1898 # 67a0 <malloc+0xc8a>
    403e:	00002097          	auipc	ra,0x2
    4042:	a1a080e7          	jalr	-1510(ra) # 5a58 <printf>
     exit(1);
    4046:	4505                	li	a0,1
    4048:	00001097          	auipc	ra,0x1
    404c:	698080e7          	jalr	1688(ra) # 56e0 <exit>
      printf("%s: preempt write error", s);
    4050:	85ca                	mv	a1,s2
    4052:	00004517          	auipc	a0,0x4
    4056:	9d650513          	addi	a0,a0,-1578 # 7a28 <malloc+0x1f12>
    405a:	00002097          	auipc	ra,0x2
    405e:	9fe080e7          	jalr	-1538(ra) # 5a58 <printf>
    4062:	b7d1                	j	4026 <preempt+0xb2>
  close(pfds[1]);
    4064:	fcc42503          	lw	a0,-52(s0)
    4068:	00001097          	auipc	ra,0x1
    406c:	6a0080e7          	jalr	1696(ra) # 5708 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    4070:	660d                	lui	a2,0x3
    4072:	00008597          	auipc	a1,0x8
    4076:	b5e58593          	addi	a1,a1,-1186 # bbd0 <buf>
    407a:	fc842503          	lw	a0,-56(s0)
    407e:	00001097          	auipc	ra,0x1
    4082:	67a080e7          	jalr	1658(ra) # 56f8 <read>
    4086:	4785                	li	a5,1
    4088:	02f50363          	beq	a0,a5,40ae <preempt+0x13a>
    printf("%s: preempt read error", s);
    408c:	85ca                	mv	a1,s2
    408e:	00004517          	auipc	a0,0x4
    4092:	9b250513          	addi	a0,a0,-1614 # 7a40 <malloc+0x1f2a>
    4096:	00002097          	auipc	ra,0x2
    409a:	9c2080e7          	jalr	-1598(ra) # 5a58 <printf>
}
    409e:	70e2                	ld	ra,56(sp)
    40a0:	7442                	ld	s0,48(sp)
    40a2:	74a2                	ld	s1,40(sp)
    40a4:	7902                	ld	s2,32(sp)
    40a6:	69e2                	ld	s3,24(sp)
    40a8:	6a42                	ld	s4,16(sp)
    40aa:	6121                	addi	sp,sp,64
    40ac:	8082                	ret
  close(pfds[0]);
    40ae:	fc842503          	lw	a0,-56(s0)
    40b2:	00001097          	auipc	ra,0x1
    40b6:	656080e7          	jalr	1622(ra) # 5708 <close>
  printf("kill... ");
    40ba:	00004517          	auipc	a0,0x4
    40be:	99e50513          	addi	a0,a0,-1634 # 7a58 <malloc+0x1f42>
    40c2:	00002097          	auipc	ra,0x2
    40c6:	996080e7          	jalr	-1642(ra) # 5a58 <printf>
  kill(pid1);
    40ca:	8526                	mv	a0,s1
    40cc:	00001097          	auipc	ra,0x1
    40d0:	644080e7          	jalr	1604(ra) # 5710 <kill>
  kill(pid2);
    40d4:	854e                	mv	a0,s3
    40d6:	00001097          	auipc	ra,0x1
    40da:	63a080e7          	jalr	1594(ra) # 5710 <kill>
  kill(pid3);
    40de:	8552                	mv	a0,s4
    40e0:	00001097          	auipc	ra,0x1
    40e4:	630080e7          	jalr	1584(ra) # 5710 <kill>
  printf("wait... ");
    40e8:	00004517          	auipc	a0,0x4
    40ec:	98050513          	addi	a0,a0,-1664 # 7a68 <malloc+0x1f52>
    40f0:	00002097          	auipc	ra,0x2
    40f4:	968080e7          	jalr	-1688(ra) # 5a58 <printf>
  wait(0);
    40f8:	4501                	li	a0,0
    40fa:	00001097          	auipc	ra,0x1
    40fe:	5ee080e7          	jalr	1518(ra) # 56e8 <wait>
  wait(0);
    4102:	4501                	li	a0,0
    4104:	00001097          	auipc	ra,0x1
    4108:	5e4080e7          	jalr	1508(ra) # 56e8 <wait>
  wait(0);
    410c:	4501                	li	a0,0
    410e:	00001097          	auipc	ra,0x1
    4112:	5da080e7          	jalr	1498(ra) # 56e8 <wait>
    4116:	b761                	j	409e <preempt+0x12a>

0000000000004118 <reparent>:
{
    4118:	7179                	addi	sp,sp,-48
    411a:	f406                	sd	ra,40(sp)
    411c:	f022                	sd	s0,32(sp)
    411e:	ec26                	sd	s1,24(sp)
    4120:	e84a                	sd	s2,16(sp)
    4122:	e44e                	sd	s3,8(sp)
    4124:	e052                	sd	s4,0(sp)
    4126:	1800                	addi	s0,sp,48
    4128:	89aa                	mv	s3,a0
  int master_pid = getpid();
    412a:	00001097          	auipc	ra,0x1
    412e:	636080e7          	jalr	1590(ra) # 5760 <getpid>
    4132:	8a2a                	mv	s4,a0
    4134:	0c800913          	li	s2,200
    int pid = fork();
    4138:	00001097          	auipc	ra,0x1
    413c:	5a0080e7          	jalr	1440(ra) # 56d8 <fork>
    4140:	84aa                	mv	s1,a0
    if(pid < 0){
    4142:	02054263          	bltz	a0,4166 <reparent+0x4e>
    if(pid){
    4146:	cd21                	beqz	a0,419e <reparent+0x86>
      if(wait(0) != pid){
    4148:	4501                	li	a0,0
    414a:	00001097          	auipc	ra,0x1
    414e:	59e080e7          	jalr	1438(ra) # 56e8 <wait>
    4152:	02951863          	bne	a0,s1,4182 <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    4156:	397d                	addiw	s2,s2,-1
    4158:	fe0910e3          	bnez	s2,4138 <reparent+0x20>
  exit(0);
    415c:	4501                	li	a0,0
    415e:	00001097          	auipc	ra,0x1
    4162:	582080e7          	jalr	1410(ra) # 56e0 <exit>
      printf("%s: fork failed\n", s);
    4166:	85ce                	mv	a1,s3
    4168:	00002517          	auipc	a0,0x2
    416c:	63850513          	addi	a0,a0,1592 # 67a0 <malloc+0xc8a>
    4170:	00002097          	auipc	ra,0x2
    4174:	8e8080e7          	jalr	-1816(ra) # 5a58 <printf>
      exit(1);
    4178:	4505                	li	a0,1
    417a:	00001097          	auipc	ra,0x1
    417e:	566080e7          	jalr	1382(ra) # 56e0 <exit>
        printf("%s: wait wrong pid\n", s);
    4182:	85ce                	mv	a1,s3
    4184:	00002517          	auipc	a0,0x2
    4188:	7a450513          	addi	a0,a0,1956 # 6928 <malloc+0xe12>
    418c:	00002097          	auipc	ra,0x2
    4190:	8cc080e7          	jalr	-1844(ra) # 5a58 <printf>
        exit(1);
    4194:	4505                	li	a0,1
    4196:	00001097          	auipc	ra,0x1
    419a:	54a080e7          	jalr	1354(ra) # 56e0 <exit>
      int pid2 = fork();
    419e:	00001097          	auipc	ra,0x1
    41a2:	53a080e7          	jalr	1338(ra) # 56d8 <fork>
      if(pid2 < 0){
    41a6:	00054763          	bltz	a0,41b4 <reparent+0x9c>
      exit(0);
    41aa:	4501                	li	a0,0
    41ac:	00001097          	auipc	ra,0x1
    41b0:	534080e7          	jalr	1332(ra) # 56e0 <exit>
        kill(master_pid);
    41b4:	8552                	mv	a0,s4
    41b6:	00001097          	auipc	ra,0x1
    41ba:	55a080e7          	jalr	1370(ra) # 5710 <kill>
        exit(1);
    41be:	4505                	li	a0,1
    41c0:	00001097          	auipc	ra,0x1
    41c4:	520080e7          	jalr	1312(ra) # 56e0 <exit>

00000000000041c8 <sbrkfail>:
{
    41c8:	7119                	addi	sp,sp,-128
    41ca:	fc86                	sd	ra,120(sp)
    41cc:	f8a2                	sd	s0,112(sp)
    41ce:	f4a6                	sd	s1,104(sp)
    41d0:	f0ca                	sd	s2,96(sp)
    41d2:	ecce                	sd	s3,88(sp)
    41d4:	e8d2                	sd	s4,80(sp)
    41d6:	e4d6                	sd	s5,72(sp)
    41d8:	0100                	addi	s0,sp,128
    41da:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    41dc:	fb040513          	addi	a0,s0,-80
    41e0:	00001097          	auipc	ra,0x1
    41e4:	510080e7          	jalr	1296(ra) # 56f0 <pipe>
    41e8:	e901                	bnez	a0,41f8 <sbrkfail+0x30>
    41ea:	f8040493          	addi	s1,s0,-128
    41ee:	fa840993          	addi	s3,s0,-88
    41f2:	8926                	mv	s2,s1
    if(pids[i] != -1)
    41f4:	5a7d                	li	s4,-1
    41f6:	a085                	j	4256 <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    41f8:	85d6                	mv	a1,s5
    41fa:	00002517          	auipc	a0,0x2
    41fe:	6ae50513          	addi	a0,a0,1710 # 68a8 <malloc+0xd92>
    4202:	00002097          	auipc	ra,0x2
    4206:	856080e7          	jalr	-1962(ra) # 5a58 <printf>
    exit(1);
    420a:	4505                	li	a0,1
    420c:	00001097          	auipc	ra,0x1
    4210:	4d4080e7          	jalr	1236(ra) # 56e0 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    4214:	00001097          	auipc	ra,0x1
    4218:	554080e7          	jalr	1364(ra) # 5768 <sbrk>
    421c:	064007b7          	lui	a5,0x6400
    4220:	40a7853b          	subw	a0,a5,a0
    4224:	00001097          	auipc	ra,0x1
    4228:	544080e7          	jalr	1348(ra) # 5768 <sbrk>
      write(fds[1], "x", 1);
    422c:	4605                	li	a2,1
    422e:	00002597          	auipc	a1,0x2
    4232:	daa58593          	addi	a1,a1,-598 # 5fd8 <malloc+0x4c2>
    4236:	fb442503          	lw	a0,-76(s0)
    423a:	00001097          	auipc	ra,0x1
    423e:	4c6080e7          	jalr	1222(ra) # 5700 <write>
      for(;;) sleep(1000);
    4242:	3e800513          	li	a0,1000
    4246:	00001097          	auipc	ra,0x1
    424a:	52a080e7          	jalr	1322(ra) # 5770 <sleep>
    424e:	bfd5                	j	4242 <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4250:	0911                	addi	s2,s2,4
    4252:	03390563          	beq	s2,s3,427c <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    4256:	00001097          	auipc	ra,0x1
    425a:	482080e7          	jalr	1154(ra) # 56d8 <fork>
    425e:	00a92023          	sw	a0,0(s2)
    4262:	d94d                	beqz	a0,4214 <sbrkfail+0x4c>
    if(pids[i] != -1)
    4264:	ff4506e3          	beq	a0,s4,4250 <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    4268:	4605                	li	a2,1
    426a:	faf40593          	addi	a1,s0,-81
    426e:	fb042503          	lw	a0,-80(s0)
    4272:	00001097          	auipc	ra,0x1
    4276:	486080e7          	jalr	1158(ra) # 56f8 <read>
    427a:	bfd9                	j	4250 <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    427c:	6505                	lui	a0,0x1
    427e:	00001097          	auipc	ra,0x1
    4282:	4ea080e7          	jalr	1258(ra) # 5768 <sbrk>
    4286:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    4288:	597d                	li	s2,-1
    428a:	a021                	j	4292 <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    428c:	0491                	addi	s1,s1,4
    428e:	01348f63          	beq	s1,s3,42ac <sbrkfail+0xe4>
    if(pids[i] == -1)
    4292:	4088                	lw	a0,0(s1)
    4294:	ff250ce3          	beq	a0,s2,428c <sbrkfail+0xc4>
    kill(pids[i]);
    4298:	00001097          	auipc	ra,0x1
    429c:	478080e7          	jalr	1144(ra) # 5710 <kill>
    wait(0);
    42a0:	4501                	li	a0,0
    42a2:	00001097          	auipc	ra,0x1
    42a6:	446080e7          	jalr	1094(ra) # 56e8 <wait>
    42aa:	b7cd                	j	428c <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    42ac:	57fd                	li	a5,-1
    42ae:	04fa0163          	beq	s4,a5,42f0 <sbrkfail+0x128>
  pid = fork();
    42b2:	00001097          	auipc	ra,0x1
    42b6:	426080e7          	jalr	1062(ra) # 56d8 <fork>
    42ba:	84aa                	mv	s1,a0
  if(pid < 0){
    42bc:	04054863          	bltz	a0,430c <sbrkfail+0x144>
  if(pid == 0){
    42c0:	c525                	beqz	a0,4328 <sbrkfail+0x160>
  wait(&xstatus);
    42c2:	fbc40513          	addi	a0,s0,-68
    42c6:	00001097          	auipc	ra,0x1
    42ca:	422080e7          	jalr	1058(ra) # 56e8 <wait>
  if(xstatus != -1 && xstatus != 2)
    42ce:	fbc42783          	lw	a5,-68(s0)
    42d2:	577d                	li	a4,-1
    42d4:	00e78563          	beq	a5,a4,42de <sbrkfail+0x116>
    42d8:	4709                	li	a4,2
    42da:	08e79d63          	bne	a5,a4,4374 <sbrkfail+0x1ac>
}
    42de:	70e6                	ld	ra,120(sp)
    42e0:	7446                	ld	s0,112(sp)
    42e2:	74a6                	ld	s1,104(sp)
    42e4:	7906                	ld	s2,96(sp)
    42e6:	69e6                	ld	s3,88(sp)
    42e8:	6a46                	ld	s4,80(sp)
    42ea:	6aa6                	ld	s5,72(sp)
    42ec:	6109                	addi	sp,sp,128
    42ee:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    42f0:	85d6                	mv	a1,s5
    42f2:	00003517          	auipc	a0,0x3
    42f6:	78650513          	addi	a0,a0,1926 # 7a78 <malloc+0x1f62>
    42fa:	00001097          	auipc	ra,0x1
    42fe:	75e080e7          	jalr	1886(ra) # 5a58 <printf>
    exit(1);
    4302:	4505                	li	a0,1
    4304:	00001097          	auipc	ra,0x1
    4308:	3dc080e7          	jalr	988(ra) # 56e0 <exit>
    printf("%s: fork failed\n", s);
    430c:	85d6                	mv	a1,s5
    430e:	00002517          	auipc	a0,0x2
    4312:	49250513          	addi	a0,a0,1170 # 67a0 <malloc+0xc8a>
    4316:	00001097          	auipc	ra,0x1
    431a:	742080e7          	jalr	1858(ra) # 5a58 <printf>
    exit(1);
    431e:	4505                	li	a0,1
    4320:	00001097          	auipc	ra,0x1
    4324:	3c0080e7          	jalr	960(ra) # 56e0 <exit>
    a = sbrk(0);
    4328:	4501                	li	a0,0
    432a:	00001097          	auipc	ra,0x1
    432e:	43e080e7          	jalr	1086(ra) # 5768 <sbrk>
    4332:	892a                	mv	s2,a0
    sbrk(10*BIG);
    4334:	3e800537          	lui	a0,0x3e800
    4338:	00001097          	auipc	ra,0x1
    433c:	430080e7          	jalr	1072(ra) # 5768 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4340:	87ca                	mv	a5,s2
    4342:	3e800737          	lui	a4,0x3e800
    4346:	993a                	add	s2,s2,a4
    4348:	6705                	lui	a4,0x1
      n += *(a+i);
    434a:	0007c683          	lbu	a3,0(a5) # 6400000 <__BSS_END__+0x63f1420>
    434e:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4350:	97ba                	add	a5,a5,a4
    4352:	ff279ce3          	bne	a5,s2,434a <sbrkfail+0x182>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    4356:	8626                	mv	a2,s1
    4358:	85d6                	mv	a1,s5
    435a:	00003517          	auipc	a0,0x3
    435e:	73e50513          	addi	a0,a0,1854 # 7a98 <malloc+0x1f82>
    4362:	00001097          	auipc	ra,0x1
    4366:	6f6080e7          	jalr	1782(ra) # 5a58 <printf>
    exit(1);
    436a:	4505                	li	a0,1
    436c:	00001097          	auipc	ra,0x1
    4370:	374080e7          	jalr	884(ra) # 56e0 <exit>
    exit(1);
    4374:	4505                	li	a0,1
    4376:	00001097          	auipc	ra,0x1
    437a:	36a080e7          	jalr	874(ra) # 56e0 <exit>

000000000000437e <mem>:
{
    437e:	7139                	addi	sp,sp,-64
    4380:	fc06                	sd	ra,56(sp)
    4382:	f822                	sd	s0,48(sp)
    4384:	f426                	sd	s1,40(sp)
    4386:	f04a                	sd	s2,32(sp)
    4388:	ec4e                	sd	s3,24(sp)
    438a:	0080                	addi	s0,sp,64
    438c:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    438e:	00001097          	auipc	ra,0x1
    4392:	34a080e7          	jalr	842(ra) # 56d8 <fork>
    m1 = 0;
    4396:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    4398:	6909                	lui	s2,0x2
    439a:	71190913          	addi	s2,s2,1809 # 2711 <sbrkbasic+0x159>
  if((pid = fork()) == 0){
    439e:	c115                	beqz	a0,43c2 <mem+0x44>
    wait(&xstatus);
    43a0:	fcc40513          	addi	a0,s0,-52
    43a4:	00001097          	auipc	ra,0x1
    43a8:	344080e7          	jalr	836(ra) # 56e8 <wait>
    if(xstatus == -1){
    43ac:	fcc42503          	lw	a0,-52(s0)
    43b0:	57fd                	li	a5,-1
    43b2:	06f50363          	beq	a0,a5,4418 <mem+0x9a>
    exit(xstatus);
    43b6:	00001097          	auipc	ra,0x1
    43ba:	32a080e7          	jalr	810(ra) # 56e0 <exit>
      *(char**)m2 = m1;
    43be:	e104                	sd	s1,0(a0)
      m1 = m2;
    43c0:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    43c2:	854a                	mv	a0,s2
    43c4:	00001097          	auipc	ra,0x1
    43c8:	752080e7          	jalr	1874(ra) # 5b16 <malloc>
    43cc:	f96d                	bnez	a0,43be <mem+0x40>
    while(m1){
    43ce:	c881                	beqz	s1,43de <mem+0x60>
      m2 = *(char**)m1;
    43d0:	8526                	mv	a0,s1
    43d2:	6084                	ld	s1,0(s1)
      free(m1);
    43d4:	00001097          	auipc	ra,0x1
    43d8:	6ba080e7          	jalr	1722(ra) # 5a8e <free>
    while(m1){
    43dc:	f8f5                	bnez	s1,43d0 <mem+0x52>
    m1 = malloc(1024*20);
    43de:	6515                	lui	a0,0x5
    43e0:	00001097          	auipc	ra,0x1
    43e4:	736080e7          	jalr	1846(ra) # 5b16 <malloc>
    if(m1 == 0){
    43e8:	c911                	beqz	a0,43fc <mem+0x7e>
    free(m1);
    43ea:	00001097          	auipc	ra,0x1
    43ee:	6a4080e7          	jalr	1700(ra) # 5a8e <free>
    exit(0);
    43f2:	4501                	li	a0,0
    43f4:	00001097          	auipc	ra,0x1
    43f8:	2ec080e7          	jalr	748(ra) # 56e0 <exit>
      printf("couldn't allocate mem?!!\n", s);
    43fc:	85ce                	mv	a1,s3
    43fe:	00003517          	auipc	a0,0x3
    4402:	6ca50513          	addi	a0,a0,1738 # 7ac8 <malloc+0x1fb2>
    4406:	00001097          	auipc	ra,0x1
    440a:	652080e7          	jalr	1618(ra) # 5a58 <printf>
      exit(1);
    440e:	4505                	li	a0,1
    4410:	00001097          	auipc	ra,0x1
    4414:	2d0080e7          	jalr	720(ra) # 56e0 <exit>
      exit(0);
    4418:	4501                	li	a0,0
    441a:	00001097          	auipc	ra,0x1
    441e:	2c6080e7          	jalr	710(ra) # 56e0 <exit>

0000000000004422 <sharedfd>:
{
    4422:	7159                	addi	sp,sp,-112
    4424:	f486                	sd	ra,104(sp)
    4426:	f0a2                	sd	s0,96(sp)
    4428:	eca6                	sd	s1,88(sp)
    442a:	e8ca                	sd	s2,80(sp)
    442c:	e4ce                	sd	s3,72(sp)
    442e:	e0d2                	sd	s4,64(sp)
    4430:	fc56                	sd	s5,56(sp)
    4432:	f85a                	sd	s6,48(sp)
    4434:	f45e                	sd	s7,40(sp)
    4436:	1880                	addi	s0,sp,112
    4438:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    443a:	00002517          	auipc	a0,0x2
    443e:	95e50513          	addi	a0,a0,-1698 # 5d98 <malloc+0x282>
    4442:	00001097          	auipc	ra,0x1
    4446:	2ee080e7          	jalr	750(ra) # 5730 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    444a:	20200593          	li	a1,514
    444e:	00002517          	auipc	a0,0x2
    4452:	94a50513          	addi	a0,a0,-1718 # 5d98 <malloc+0x282>
    4456:	00001097          	auipc	ra,0x1
    445a:	2ca080e7          	jalr	714(ra) # 5720 <open>
  if(fd < 0){
    445e:	04054a63          	bltz	a0,44b2 <sharedfd+0x90>
    4462:	892a                	mv	s2,a0
  pid = fork();
    4464:	00001097          	auipc	ra,0x1
    4468:	274080e7          	jalr	628(ra) # 56d8 <fork>
    446c:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    446e:	06300593          	li	a1,99
    4472:	c119                	beqz	a0,4478 <sharedfd+0x56>
    4474:	07000593          	li	a1,112
    4478:	4629                	li	a2,10
    447a:	fa040513          	addi	a0,s0,-96
    447e:	00001097          	auipc	ra,0x1
    4482:	066080e7          	jalr	102(ra) # 54e4 <memset>
    4486:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    448a:	4629                	li	a2,10
    448c:	fa040593          	addi	a1,s0,-96
    4490:	854a                	mv	a0,s2
    4492:	00001097          	auipc	ra,0x1
    4496:	26e080e7          	jalr	622(ra) # 5700 <write>
    449a:	47a9                	li	a5,10
    449c:	02f51963          	bne	a0,a5,44ce <sharedfd+0xac>
  for(i = 0; i < N; i++){
    44a0:	34fd                	addiw	s1,s1,-1
    44a2:	f4e5                	bnez	s1,448a <sharedfd+0x68>
  if(pid == 0) {
    44a4:	04099363          	bnez	s3,44ea <sharedfd+0xc8>
    exit(0);
    44a8:	4501                	li	a0,0
    44aa:	00001097          	auipc	ra,0x1
    44ae:	236080e7          	jalr	566(ra) # 56e0 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    44b2:	85d2                	mv	a1,s4
    44b4:	00003517          	auipc	a0,0x3
    44b8:	63450513          	addi	a0,a0,1588 # 7ae8 <malloc+0x1fd2>
    44bc:	00001097          	auipc	ra,0x1
    44c0:	59c080e7          	jalr	1436(ra) # 5a58 <printf>
    exit(1);
    44c4:	4505                	li	a0,1
    44c6:	00001097          	auipc	ra,0x1
    44ca:	21a080e7          	jalr	538(ra) # 56e0 <exit>
      printf("%s: write sharedfd failed\n", s);
    44ce:	85d2                	mv	a1,s4
    44d0:	00003517          	auipc	a0,0x3
    44d4:	64050513          	addi	a0,a0,1600 # 7b10 <malloc+0x1ffa>
    44d8:	00001097          	auipc	ra,0x1
    44dc:	580080e7          	jalr	1408(ra) # 5a58 <printf>
      exit(1);
    44e0:	4505                	li	a0,1
    44e2:	00001097          	auipc	ra,0x1
    44e6:	1fe080e7          	jalr	510(ra) # 56e0 <exit>
    wait(&xstatus);
    44ea:	f9c40513          	addi	a0,s0,-100
    44ee:	00001097          	auipc	ra,0x1
    44f2:	1fa080e7          	jalr	506(ra) # 56e8 <wait>
    if(xstatus != 0)
    44f6:	f9c42983          	lw	s3,-100(s0)
    44fa:	00098763          	beqz	s3,4508 <sharedfd+0xe6>
      exit(xstatus);
    44fe:	854e                	mv	a0,s3
    4500:	00001097          	auipc	ra,0x1
    4504:	1e0080e7          	jalr	480(ra) # 56e0 <exit>
  close(fd);
    4508:	854a                	mv	a0,s2
    450a:	00001097          	auipc	ra,0x1
    450e:	1fe080e7          	jalr	510(ra) # 5708 <close>
  fd = open("sharedfd", 0);
    4512:	4581                	li	a1,0
    4514:	00002517          	auipc	a0,0x2
    4518:	88450513          	addi	a0,a0,-1916 # 5d98 <malloc+0x282>
    451c:	00001097          	auipc	ra,0x1
    4520:	204080e7          	jalr	516(ra) # 5720 <open>
    4524:	8baa                	mv	s7,a0
  nc = np = 0;
    4526:	8ace                	mv	s5,s3
  if(fd < 0){
    4528:	02054563          	bltz	a0,4552 <sharedfd+0x130>
    452c:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    4530:	06300493          	li	s1,99
      if(buf[i] == 'p')
    4534:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    4538:	4629                	li	a2,10
    453a:	fa040593          	addi	a1,s0,-96
    453e:	855e                	mv	a0,s7
    4540:	00001097          	auipc	ra,0x1
    4544:	1b8080e7          	jalr	440(ra) # 56f8 <read>
    4548:	02a05f63          	blez	a0,4586 <sharedfd+0x164>
    454c:	fa040793          	addi	a5,s0,-96
    4550:	a01d                	j	4576 <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    4552:	85d2                	mv	a1,s4
    4554:	00003517          	auipc	a0,0x3
    4558:	5dc50513          	addi	a0,a0,1500 # 7b30 <malloc+0x201a>
    455c:	00001097          	auipc	ra,0x1
    4560:	4fc080e7          	jalr	1276(ra) # 5a58 <printf>
    exit(1);
    4564:	4505                	li	a0,1
    4566:	00001097          	auipc	ra,0x1
    456a:	17a080e7          	jalr	378(ra) # 56e0 <exit>
        nc++;
    456e:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    4570:	0785                	addi	a5,a5,1
    4572:	fd2783e3          	beq	a5,s2,4538 <sharedfd+0x116>
      if(buf[i] == 'c')
    4576:	0007c703          	lbu	a4,0(a5)
    457a:	fe970ae3          	beq	a4,s1,456e <sharedfd+0x14c>
      if(buf[i] == 'p')
    457e:	ff6719e3          	bne	a4,s6,4570 <sharedfd+0x14e>
        np++;
    4582:	2a85                	addiw	s5,s5,1
    4584:	b7f5                	j	4570 <sharedfd+0x14e>
  close(fd);
    4586:	855e                	mv	a0,s7
    4588:	00001097          	auipc	ra,0x1
    458c:	180080e7          	jalr	384(ra) # 5708 <close>
  unlink("sharedfd");
    4590:	00002517          	auipc	a0,0x2
    4594:	80850513          	addi	a0,a0,-2040 # 5d98 <malloc+0x282>
    4598:	00001097          	auipc	ra,0x1
    459c:	198080e7          	jalr	408(ra) # 5730 <unlink>
  if(nc == N*SZ && np == N*SZ){
    45a0:	6789                	lui	a5,0x2
    45a2:	71078793          	addi	a5,a5,1808 # 2710 <sbrkbasic+0x158>
    45a6:	00f99763          	bne	s3,a5,45b4 <sharedfd+0x192>
    45aa:	6789                	lui	a5,0x2
    45ac:	71078793          	addi	a5,a5,1808 # 2710 <sbrkbasic+0x158>
    45b0:	02fa8063          	beq	s5,a5,45d0 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    45b4:	85d2                	mv	a1,s4
    45b6:	00003517          	auipc	a0,0x3
    45ba:	5a250513          	addi	a0,a0,1442 # 7b58 <malloc+0x2042>
    45be:	00001097          	auipc	ra,0x1
    45c2:	49a080e7          	jalr	1178(ra) # 5a58 <printf>
    exit(1);
    45c6:	4505                	li	a0,1
    45c8:	00001097          	auipc	ra,0x1
    45cc:	118080e7          	jalr	280(ra) # 56e0 <exit>
    exit(0);
    45d0:	4501                	li	a0,0
    45d2:	00001097          	auipc	ra,0x1
    45d6:	10e080e7          	jalr	270(ra) # 56e0 <exit>

00000000000045da <fourfiles>:
{
    45da:	7171                	addi	sp,sp,-176
    45dc:	f506                	sd	ra,168(sp)
    45de:	f122                	sd	s0,160(sp)
    45e0:	ed26                	sd	s1,152(sp)
    45e2:	e94a                	sd	s2,144(sp)
    45e4:	e54e                	sd	s3,136(sp)
    45e6:	e152                	sd	s4,128(sp)
    45e8:	fcd6                	sd	s5,120(sp)
    45ea:	f8da                	sd	s6,112(sp)
    45ec:	f4de                	sd	s7,104(sp)
    45ee:	f0e2                	sd	s8,96(sp)
    45f0:	ece6                	sd	s9,88(sp)
    45f2:	e8ea                	sd	s10,80(sp)
    45f4:	e4ee                	sd	s11,72(sp)
    45f6:	1900                	addi	s0,sp,176
    45f8:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = { "f0", "f1", "f2", "f3" };
    45fc:	00001797          	auipc	a5,0x1
    4600:	60478793          	addi	a5,a5,1540 # 5c00 <malloc+0xea>
    4604:	f6f43823          	sd	a5,-144(s0)
    4608:	00001797          	auipc	a5,0x1
    460c:	60078793          	addi	a5,a5,1536 # 5c08 <malloc+0xf2>
    4610:	f6f43c23          	sd	a5,-136(s0)
    4614:	00001797          	auipc	a5,0x1
    4618:	5fc78793          	addi	a5,a5,1532 # 5c10 <malloc+0xfa>
    461c:	f8f43023          	sd	a5,-128(s0)
    4620:	00001797          	auipc	a5,0x1
    4624:	5f878793          	addi	a5,a5,1528 # 5c18 <malloc+0x102>
    4628:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    462c:	f7040c13          	addi	s8,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    4630:	8962                	mv	s2,s8
  for(pi = 0; pi < NCHILD; pi++){
    4632:	4481                	li	s1,0
    4634:	4a11                	li	s4,4
    fname = names[pi];
    4636:	00093983          	ld	s3,0(s2)
    unlink(fname);
    463a:	854e                	mv	a0,s3
    463c:	00001097          	auipc	ra,0x1
    4640:	0f4080e7          	jalr	244(ra) # 5730 <unlink>
    pid = fork();
    4644:	00001097          	auipc	ra,0x1
    4648:	094080e7          	jalr	148(ra) # 56d8 <fork>
    if(pid < 0){
    464c:	04054463          	bltz	a0,4694 <fourfiles+0xba>
    if(pid == 0){
    4650:	c12d                	beqz	a0,46b2 <fourfiles+0xd8>
  for(pi = 0; pi < NCHILD; pi++){
    4652:	2485                	addiw	s1,s1,1
    4654:	0921                	addi	s2,s2,8
    4656:	ff4490e3          	bne	s1,s4,4636 <fourfiles+0x5c>
    465a:	4491                	li	s1,4
    wait(&xstatus);
    465c:	f6c40513          	addi	a0,s0,-148
    4660:	00001097          	auipc	ra,0x1
    4664:	088080e7          	jalr	136(ra) # 56e8 <wait>
    if(xstatus != 0)
    4668:	f6c42b03          	lw	s6,-148(s0)
    466c:	0c0b1e63          	bnez	s6,4748 <fourfiles+0x16e>
  for(pi = 0; pi < NCHILD; pi++){
    4670:	34fd                	addiw	s1,s1,-1
    4672:	f4ed                	bnez	s1,465c <fourfiles+0x82>
    4674:	03000b93          	li	s7,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4678:	00007a17          	auipc	s4,0x7
    467c:	558a0a13          	addi	s4,s4,1368 # bbd0 <buf>
    4680:	00007a97          	auipc	s5,0x7
    4684:	551a8a93          	addi	s5,s5,1361 # bbd1 <buf+0x1>
    if(total != N*SZ){
    4688:	6d85                	lui	s11,0x1
    468a:	770d8d93          	addi	s11,s11,1904 # 1770 <pipe1+0x32>
  for(i = 0; i < NCHILD; i++){
    468e:	03400d13          	li	s10,52
    4692:	aa1d                	j	47c8 <fourfiles+0x1ee>
      printf("fork failed\n", s);
    4694:	f5843583          	ld	a1,-168(s0)
    4698:	00002517          	auipc	a0,0x2
    469c:	51050513          	addi	a0,a0,1296 # 6ba8 <malloc+0x1092>
    46a0:	00001097          	auipc	ra,0x1
    46a4:	3b8080e7          	jalr	952(ra) # 5a58 <printf>
      exit(1);
    46a8:	4505                	li	a0,1
    46aa:	00001097          	auipc	ra,0x1
    46ae:	036080e7          	jalr	54(ra) # 56e0 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    46b2:	20200593          	li	a1,514
    46b6:	854e                	mv	a0,s3
    46b8:	00001097          	auipc	ra,0x1
    46bc:	068080e7          	jalr	104(ra) # 5720 <open>
    46c0:	892a                	mv	s2,a0
      if(fd < 0){
    46c2:	04054763          	bltz	a0,4710 <fourfiles+0x136>
      memset(buf, '0'+pi, SZ);
    46c6:	1f400613          	li	a2,500
    46ca:	0304859b          	addiw	a1,s1,48
    46ce:	00007517          	auipc	a0,0x7
    46d2:	50250513          	addi	a0,a0,1282 # bbd0 <buf>
    46d6:	00001097          	auipc	ra,0x1
    46da:	e0e080e7          	jalr	-498(ra) # 54e4 <memset>
    46de:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    46e0:	00007997          	auipc	s3,0x7
    46e4:	4f098993          	addi	s3,s3,1264 # bbd0 <buf>
    46e8:	1f400613          	li	a2,500
    46ec:	85ce                	mv	a1,s3
    46ee:	854a                	mv	a0,s2
    46f0:	00001097          	auipc	ra,0x1
    46f4:	010080e7          	jalr	16(ra) # 5700 <write>
    46f8:	85aa                	mv	a1,a0
    46fa:	1f400793          	li	a5,500
    46fe:	02f51863          	bne	a0,a5,472e <fourfiles+0x154>
      for(i = 0; i < N; i++){
    4702:	34fd                	addiw	s1,s1,-1
    4704:	f0f5                	bnez	s1,46e8 <fourfiles+0x10e>
      exit(0);
    4706:	4501                	li	a0,0
    4708:	00001097          	auipc	ra,0x1
    470c:	fd8080e7          	jalr	-40(ra) # 56e0 <exit>
        printf("create failed\n", s);
    4710:	f5843583          	ld	a1,-168(s0)
    4714:	00003517          	auipc	a0,0x3
    4718:	45c50513          	addi	a0,a0,1116 # 7b70 <malloc+0x205a>
    471c:	00001097          	auipc	ra,0x1
    4720:	33c080e7          	jalr	828(ra) # 5a58 <printf>
        exit(1);
    4724:	4505                	li	a0,1
    4726:	00001097          	auipc	ra,0x1
    472a:	fba080e7          	jalr	-70(ra) # 56e0 <exit>
          printf("write failed %d\n", n);
    472e:	00003517          	auipc	a0,0x3
    4732:	45250513          	addi	a0,a0,1106 # 7b80 <malloc+0x206a>
    4736:	00001097          	auipc	ra,0x1
    473a:	322080e7          	jalr	802(ra) # 5a58 <printf>
          exit(1);
    473e:	4505                	li	a0,1
    4740:	00001097          	auipc	ra,0x1
    4744:	fa0080e7          	jalr	-96(ra) # 56e0 <exit>
      exit(xstatus);
    4748:	855a                	mv	a0,s6
    474a:	00001097          	auipc	ra,0x1
    474e:	f96080e7          	jalr	-106(ra) # 56e0 <exit>
          printf("wrong char\n", s);
    4752:	f5843583          	ld	a1,-168(s0)
    4756:	00003517          	auipc	a0,0x3
    475a:	44250513          	addi	a0,a0,1090 # 7b98 <malloc+0x2082>
    475e:	00001097          	auipc	ra,0x1
    4762:	2fa080e7          	jalr	762(ra) # 5a58 <printf>
          exit(1);
    4766:	4505                	li	a0,1
    4768:	00001097          	auipc	ra,0x1
    476c:	f78080e7          	jalr	-136(ra) # 56e0 <exit>
      total += n;
    4770:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4774:	660d                	lui	a2,0x3
    4776:	85d2                	mv	a1,s4
    4778:	854e                	mv	a0,s3
    477a:	00001097          	auipc	ra,0x1
    477e:	f7e080e7          	jalr	-130(ra) # 56f8 <read>
    4782:	02a05363          	blez	a0,47a8 <fourfiles+0x1ce>
    4786:	00007797          	auipc	a5,0x7
    478a:	44a78793          	addi	a5,a5,1098 # bbd0 <buf>
    478e:	fff5069b          	addiw	a3,a0,-1
    4792:	1682                	slli	a3,a3,0x20
    4794:	9281                	srli	a3,a3,0x20
    4796:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    4798:	0007c703          	lbu	a4,0(a5)
    479c:	fa971be3          	bne	a4,s1,4752 <fourfiles+0x178>
      for(j = 0; j < n; j++){
    47a0:	0785                	addi	a5,a5,1
    47a2:	fed79be3          	bne	a5,a3,4798 <fourfiles+0x1be>
    47a6:	b7e9                	j	4770 <fourfiles+0x196>
    close(fd);
    47a8:	854e                	mv	a0,s3
    47aa:	00001097          	auipc	ra,0x1
    47ae:	f5e080e7          	jalr	-162(ra) # 5708 <close>
    if(total != N*SZ){
    47b2:	03b91863          	bne	s2,s11,47e2 <fourfiles+0x208>
    unlink(fname);
    47b6:	8566                	mv	a0,s9
    47b8:	00001097          	auipc	ra,0x1
    47bc:	f78080e7          	jalr	-136(ra) # 5730 <unlink>
  for(i = 0; i < NCHILD; i++){
    47c0:	0c21                	addi	s8,s8,8
    47c2:	2b85                	addiw	s7,s7,1
    47c4:	03ab8d63          	beq	s7,s10,47fe <fourfiles+0x224>
    fname = names[i];
    47c8:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    47cc:	4581                	li	a1,0
    47ce:	8566                	mv	a0,s9
    47d0:	00001097          	auipc	ra,0x1
    47d4:	f50080e7          	jalr	-176(ra) # 5720 <open>
    47d8:	89aa                	mv	s3,a0
    total = 0;
    47da:	895a                	mv	s2,s6
        if(buf[j] != '0'+i){
    47dc:	000b849b          	sext.w	s1,s7
    while((n = read(fd, buf, sizeof(buf))) > 0){
    47e0:	bf51                	j	4774 <fourfiles+0x19a>
      printf("wrong length %d\n", total);
    47e2:	85ca                	mv	a1,s2
    47e4:	00003517          	auipc	a0,0x3
    47e8:	3c450513          	addi	a0,a0,964 # 7ba8 <malloc+0x2092>
    47ec:	00001097          	auipc	ra,0x1
    47f0:	26c080e7          	jalr	620(ra) # 5a58 <printf>
      exit(1);
    47f4:	4505                	li	a0,1
    47f6:	00001097          	auipc	ra,0x1
    47fa:	eea080e7          	jalr	-278(ra) # 56e0 <exit>
}
    47fe:	70aa                	ld	ra,168(sp)
    4800:	740a                	ld	s0,160(sp)
    4802:	64ea                	ld	s1,152(sp)
    4804:	694a                	ld	s2,144(sp)
    4806:	69aa                	ld	s3,136(sp)
    4808:	6a0a                	ld	s4,128(sp)
    480a:	7ae6                	ld	s5,120(sp)
    480c:	7b46                	ld	s6,112(sp)
    480e:	7ba6                	ld	s7,104(sp)
    4810:	7c06                	ld	s8,96(sp)
    4812:	6ce6                	ld	s9,88(sp)
    4814:	6d46                	ld	s10,80(sp)
    4816:	6da6                	ld	s11,72(sp)
    4818:	614d                	addi	sp,sp,176
    481a:	8082                	ret

000000000000481c <concreate>:
{
    481c:	7135                	addi	sp,sp,-160
    481e:	ed06                	sd	ra,152(sp)
    4820:	e922                	sd	s0,144(sp)
    4822:	e526                	sd	s1,136(sp)
    4824:	e14a                	sd	s2,128(sp)
    4826:	fcce                	sd	s3,120(sp)
    4828:	f8d2                	sd	s4,112(sp)
    482a:	f4d6                	sd	s5,104(sp)
    482c:	f0da                	sd	s6,96(sp)
    482e:	ecde                	sd	s7,88(sp)
    4830:	1100                	addi	s0,sp,160
    4832:	89aa                	mv	s3,a0
  file[0] = 'C';
    4834:	04300793          	li	a5,67
    4838:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    483c:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    4840:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    4842:	4b0d                	li	s6,3
    4844:	4a85                	li	s5,1
      link("C0", file);
    4846:	00003b97          	auipc	s7,0x3
    484a:	37ab8b93          	addi	s7,s7,890 # 7bc0 <malloc+0x20aa>
  for(i = 0; i < N; i++){
    484e:	02800a13          	li	s4,40
    4852:	acc1                	j	4b22 <concreate+0x306>
      link("C0", file);
    4854:	fa840593          	addi	a1,s0,-88
    4858:	855e                	mv	a0,s7
    485a:	00001097          	auipc	ra,0x1
    485e:	ee6080e7          	jalr	-282(ra) # 5740 <link>
    if(pid == 0) {
    4862:	a45d                	j	4b08 <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    4864:	4795                	li	a5,5
    4866:	02f9693b          	remw	s2,s2,a5
    486a:	4785                	li	a5,1
    486c:	02f90b63          	beq	s2,a5,48a2 <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    4870:	20200593          	li	a1,514
    4874:	fa840513          	addi	a0,s0,-88
    4878:	00001097          	auipc	ra,0x1
    487c:	ea8080e7          	jalr	-344(ra) # 5720 <open>
      if(fd < 0){
    4880:	26055b63          	bgez	a0,4af6 <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    4884:	fa840593          	addi	a1,s0,-88
    4888:	00003517          	auipc	a0,0x3
    488c:	34050513          	addi	a0,a0,832 # 7bc8 <malloc+0x20b2>
    4890:	00001097          	auipc	ra,0x1
    4894:	1c8080e7          	jalr	456(ra) # 5a58 <printf>
        exit(1);
    4898:	4505                	li	a0,1
    489a:	00001097          	auipc	ra,0x1
    489e:	e46080e7          	jalr	-442(ra) # 56e0 <exit>
      link("C0", file);
    48a2:	fa840593          	addi	a1,s0,-88
    48a6:	00003517          	auipc	a0,0x3
    48aa:	31a50513          	addi	a0,a0,794 # 7bc0 <malloc+0x20aa>
    48ae:	00001097          	auipc	ra,0x1
    48b2:	e92080e7          	jalr	-366(ra) # 5740 <link>
      exit(0);
    48b6:	4501                	li	a0,0
    48b8:	00001097          	auipc	ra,0x1
    48bc:	e28080e7          	jalr	-472(ra) # 56e0 <exit>
        exit(1);
    48c0:	4505                	li	a0,1
    48c2:	00001097          	auipc	ra,0x1
    48c6:	e1e080e7          	jalr	-482(ra) # 56e0 <exit>
  memset(fa, 0, sizeof(fa));
    48ca:	02800613          	li	a2,40
    48ce:	4581                	li	a1,0
    48d0:	f8040513          	addi	a0,s0,-128
    48d4:	00001097          	auipc	ra,0x1
    48d8:	c10080e7          	jalr	-1008(ra) # 54e4 <memset>
  fd = open(".", 0);
    48dc:	4581                	li	a1,0
    48de:	00002517          	auipc	a0,0x2
    48e2:	d2250513          	addi	a0,a0,-734 # 6600 <malloc+0xaea>
    48e6:	00001097          	auipc	ra,0x1
    48ea:	e3a080e7          	jalr	-454(ra) # 5720 <open>
    48ee:	892a                	mv	s2,a0
  n = 0;
    48f0:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    48f2:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    48f6:	02700b13          	li	s6,39
      fa[i] = 1;
    48fa:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    48fc:	4641                	li	a2,16
    48fe:	f7040593          	addi	a1,s0,-144
    4902:	854a                	mv	a0,s2
    4904:	00001097          	auipc	ra,0x1
    4908:	df4080e7          	jalr	-524(ra) # 56f8 <read>
    490c:	08a05163          	blez	a0,498e <concreate+0x172>
    if(de.inum == 0)
    4910:	f7045783          	lhu	a5,-144(s0)
    4914:	d7e5                	beqz	a5,48fc <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4916:	f7244783          	lbu	a5,-142(s0)
    491a:	ff4791e3          	bne	a5,s4,48fc <concreate+0xe0>
    491e:	f7444783          	lbu	a5,-140(s0)
    4922:	ffe9                	bnez	a5,48fc <concreate+0xe0>
      i = de.name[1] - '0';
    4924:	f7344783          	lbu	a5,-141(s0)
    4928:	fd07879b          	addiw	a5,a5,-48
    492c:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    4930:	00eb6f63          	bltu	s6,a4,494e <concreate+0x132>
      if(fa[i]){
    4934:	fb040793          	addi	a5,s0,-80
    4938:	97ba                	add	a5,a5,a4
    493a:	fd07c783          	lbu	a5,-48(a5)
    493e:	eb85                	bnez	a5,496e <concreate+0x152>
      fa[i] = 1;
    4940:	fb040793          	addi	a5,s0,-80
    4944:	973e                	add	a4,a4,a5
    4946:	fd770823          	sb	s7,-48(a4) # fd0 <bigdir+0x6e>
      n++;
    494a:	2a85                	addiw	s5,s5,1
    494c:	bf45                	j	48fc <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    494e:	f7240613          	addi	a2,s0,-142
    4952:	85ce                	mv	a1,s3
    4954:	00003517          	auipc	a0,0x3
    4958:	29450513          	addi	a0,a0,660 # 7be8 <malloc+0x20d2>
    495c:	00001097          	auipc	ra,0x1
    4960:	0fc080e7          	jalr	252(ra) # 5a58 <printf>
        exit(1);
    4964:	4505                	li	a0,1
    4966:	00001097          	auipc	ra,0x1
    496a:	d7a080e7          	jalr	-646(ra) # 56e0 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    496e:	f7240613          	addi	a2,s0,-142
    4972:	85ce                	mv	a1,s3
    4974:	00003517          	auipc	a0,0x3
    4978:	29450513          	addi	a0,a0,660 # 7c08 <malloc+0x20f2>
    497c:	00001097          	auipc	ra,0x1
    4980:	0dc080e7          	jalr	220(ra) # 5a58 <printf>
        exit(1);
    4984:	4505                	li	a0,1
    4986:	00001097          	auipc	ra,0x1
    498a:	d5a080e7          	jalr	-678(ra) # 56e0 <exit>
  close(fd);
    498e:	854a                	mv	a0,s2
    4990:	00001097          	auipc	ra,0x1
    4994:	d78080e7          	jalr	-648(ra) # 5708 <close>
  if(n != N){
    4998:	02800793          	li	a5,40
    499c:	00fa9763          	bne	s5,a5,49aa <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    49a0:	4a8d                	li	s5,3
    49a2:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    49a4:	02800a13          	li	s4,40
    49a8:	a8c9                	j	4a7a <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    49aa:	85ce                	mv	a1,s3
    49ac:	00003517          	auipc	a0,0x3
    49b0:	28450513          	addi	a0,a0,644 # 7c30 <malloc+0x211a>
    49b4:	00001097          	auipc	ra,0x1
    49b8:	0a4080e7          	jalr	164(ra) # 5a58 <printf>
    exit(1);
    49bc:	4505                	li	a0,1
    49be:	00001097          	auipc	ra,0x1
    49c2:	d22080e7          	jalr	-734(ra) # 56e0 <exit>
      printf("%s: fork failed\n", s);
    49c6:	85ce                	mv	a1,s3
    49c8:	00002517          	auipc	a0,0x2
    49cc:	dd850513          	addi	a0,a0,-552 # 67a0 <malloc+0xc8a>
    49d0:	00001097          	auipc	ra,0x1
    49d4:	088080e7          	jalr	136(ra) # 5a58 <printf>
      exit(1);
    49d8:	4505                	li	a0,1
    49da:	00001097          	auipc	ra,0x1
    49de:	d06080e7          	jalr	-762(ra) # 56e0 <exit>
      close(open(file, 0));
    49e2:	4581                	li	a1,0
    49e4:	fa840513          	addi	a0,s0,-88
    49e8:	00001097          	auipc	ra,0x1
    49ec:	d38080e7          	jalr	-712(ra) # 5720 <open>
    49f0:	00001097          	auipc	ra,0x1
    49f4:	d18080e7          	jalr	-744(ra) # 5708 <close>
      close(open(file, 0));
    49f8:	4581                	li	a1,0
    49fa:	fa840513          	addi	a0,s0,-88
    49fe:	00001097          	auipc	ra,0x1
    4a02:	d22080e7          	jalr	-734(ra) # 5720 <open>
    4a06:	00001097          	auipc	ra,0x1
    4a0a:	d02080e7          	jalr	-766(ra) # 5708 <close>
      close(open(file, 0));
    4a0e:	4581                	li	a1,0
    4a10:	fa840513          	addi	a0,s0,-88
    4a14:	00001097          	auipc	ra,0x1
    4a18:	d0c080e7          	jalr	-756(ra) # 5720 <open>
    4a1c:	00001097          	auipc	ra,0x1
    4a20:	cec080e7          	jalr	-788(ra) # 5708 <close>
      close(open(file, 0));
    4a24:	4581                	li	a1,0
    4a26:	fa840513          	addi	a0,s0,-88
    4a2a:	00001097          	auipc	ra,0x1
    4a2e:	cf6080e7          	jalr	-778(ra) # 5720 <open>
    4a32:	00001097          	auipc	ra,0x1
    4a36:	cd6080e7          	jalr	-810(ra) # 5708 <close>
      close(open(file, 0));
    4a3a:	4581                	li	a1,0
    4a3c:	fa840513          	addi	a0,s0,-88
    4a40:	00001097          	auipc	ra,0x1
    4a44:	ce0080e7          	jalr	-800(ra) # 5720 <open>
    4a48:	00001097          	auipc	ra,0x1
    4a4c:	cc0080e7          	jalr	-832(ra) # 5708 <close>
      close(open(file, 0));
    4a50:	4581                	li	a1,0
    4a52:	fa840513          	addi	a0,s0,-88
    4a56:	00001097          	auipc	ra,0x1
    4a5a:	cca080e7          	jalr	-822(ra) # 5720 <open>
    4a5e:	00001097          	auipc	ra,0x1
    4a62:	caa080e7          	jalr	-854(ra) # 5708 <close>
    if(pid == 0)
    4a66:	08090363          	beqz	s2,4aec <concreate+0x2d0>
      wait(0);
    4a6a:	4501                	li	a0,0
    4a6c:	00001097          	auipc	ra,0x1
    4a70:	c7c080e7          	jalr	-900(ra) # 56e8 <wait>
  for(i = 0; i < N; i++){
    4a74:	2485                	addiw	s1,s1,1
    4a76:	0f448563          	beq	s1,s4,4b60 <concreate+0x344>
    file[1] = '0' + i;
    4a7a:	0304879b          	addiw	a5,s1,48
    4a7e:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    4a82:	00001097          	auipc	ra,0x1
    4a86:	c56080e7          	jalr	-938(ra) # 56d8 <fork>
    4a8a:	892a                	mv	s2,a0
    if(pid < 0){
    4a8c:	f2054de3          	bltz	a0,49c6 <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    4a90:	0354e73b          	remw	a4,s1,s5
    4a94:	00a767b3          	or	a5,a4,a0
    4a98:	2781                	sext.w	a5,a5
    4a9a:	d7a1                	beqz	a5,49e2 <concreate+0x1c6>
    4a9c:	01671363          	bne	a4,s6,4aa2 <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    4aa0:	f129                	bnez	a0,49e2 <concreate+0x1c6>
      unlink(file);
    4aa2:	fa840513          	addi	a0,s0,-88
    4aa6:	00001097          	auipc	ra,0x1
    4aaa:	c8a080e7          	jalr	-886(ra) # 5730 <unlink>
      unlink(file);
    4aae:	fa840513          	addi	a0,s0,-88
    4ab2:	00001097          	auipc	ra,0x1
    4ab6:	c7e080e7          	jalr	-898(ra) # 5730 <unlink>
      unlink(file);
    4aba:	fa840513          	addi	a0,s0,-88
    4abe:	00001097          	auipc	ra,0x1
    4ac2:	c72080e7          	jalr	-910(ra) # 5730 <unlink>
      unlink(file);
    4ac6:	fa840513          	addi	a0,s0,-88
    4aca:	00001097          	auipc	ra,0x1
    4ace:	c66080e7          	jalr	-922(ra) # 5730 <unlink>
      unlink(file);
    4ad2:	fa840513          	addi	a0,s0,-88
    4ad6:	00001097          	auipc	ra,0x1
    4ada:	c5a080e7          	jalr	-934(ra) # 5730 <unlink>
      unlink(file);
    4ade:	fa840513          	addi	a0,s0,-88
    4ae2:	00001097          	auipc	ra,0x1
    4ae6:	c4e080e7          	jalr	-946(ra) # 5730 <unlink>
    4aea:	bfb5                	j	4a66 <concreate+0x24a>
      exit(0);
    4aec:	4501                	li	a0,0
    4aee:	00001097          	auipc	ra,0x1
    4af2:	bf2080e7          	jalr	-1038(ra) # 56e0 <exit>
      close(fd);
    4af6:	00001097          	auipc	ra,0x1
    4afa:	c12080e7          	jalr	-1006(ra) # 5708 <close>
    if(pid == 0) {
    4afe:	bb65                	j	48b6 <concreate+0x9a>
      close(fd);
    4b00:	00001097          	auipc	ra,0x1
    4b04:	c08080e7          	jalr	-1016(ra) # 5708 <close>
      wait(&xstatus);
    4b08:	f6c40513          	addi	a0,s0,-148
    4b0c:	00001097          	auipc	ra,0x1
    4b10:	bdc080e7          	jalr	-1060(ra) # 56e8 <wait>
      if(xstatus != 0)
    4b14:	f6c42483          	lw	s1,-148(s0)
    4b18:	da0494e3          	bnez	s1,48c0 <concreate+0xa4>
  for(i = 0; i < N; i++){
    4b1c:	2905                	addiw	s2,s2,1
    4b1e:	db4906e3          	beq	s2,s4,48ca <concreate+0xae>
    file[1] = '0' + i;
    4b22:	0309079b          	addiw	a5,s2,48
    4b26:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    4b2a:	fa840513          	addi	a0,s0,-88
    4b2e:	00001097          	auipc	ra,0x1
    4b32:	c02080e7          	jalr	-1022(ra) # 5730 <unlink>
    pid = fork();
    4b36:	00001097          	auipc	ra,0x1
    4b3a:	ba2080e7          	jalr	-1118(ra) # 56d8 <fork>
    if(pid && (i % 3) == 1){
    4b3e:	d20503e3          	beqz	a0,4864 <concreate+0x48>
    4b42:	036967bb          	remw	a5,s2,s6
    4b46:	d15787e3          	beq	a5,s5,4854 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    4b4a:	20200593          	li	a1,514
    4b4e:	fa840513          	addi	a0,s0,-88
    4b52:	00001097          	auipc	ra,0x1
    4b56:	bce080e7          	jalr	-1074(ra) # 5720 <open>
      if(fd < 0){
    4b5a:	fa0553e3          	bgez	a0,4b00 <concreate+0x2e4>
    4b5e:	b31d                	j	4884 <concreate+0x68>
}
    4b60:	60ea                	ld	ra,152(sp)
    4b62:	644a                	ld	s0,144(sp)
    4b64:	64aa                	ld	s1,136(sp)
    4b66:	690a                	ld	s2,128(sp)
    4b68:	79e6                	ld	s3,120(sp)
    4b6a:	7a46                	ld	s4,112(sp)
    4b6c:	7aa6                	ld	s5,104(sp)
    4b6e:	7b06                	ld	s6,96(sp)
    4b70:	6be6                	ld	s7,88(sp)
    4b72:	610d                	addi	sp,sp,160
    4b74:	8082                	ret

0000000000004b76 <bigfile>:
{
    4b76:	7139                	addi	sp,sp,-64
    4b78:	fc06                	sd	ra,56(sp)
    4b7a:	f822                	sd	s0,48(sp)
    4b7c:	f426                	sd	s1,40(sp)
    4b7e:	f04a                	sd	s2,32(sp)
    4b80:	ec4e                	sd	s3,24(sp)
    4b82:	e852                	sd	s4,16(sp)
    4b84:	e456                	sd	s5,8(sp)
    4b86:	0080                	addi	s0,sp,64
    4b88:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    4b8a:	00003517          	auipc	a0,0x3
    4b8e:	0de50513          	addi	a0,a0,222 # 7c68 <malloc+0x2152>
    4b92:	00001097          	auipc	ra,0x1
    4b96:	b9e080e7          	jalr	-1122(ra) # 5730 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    4b9a:	20200593          	li	a1,514
    4b9e:	00003517          	auipc	a0,0x3
    4ba2:	0ca50513          	addi	a0,a0,202 # 7c68 <malloc+0x2152>
    4ba6:	00001097          	auipc	ra,0x1
    4baa:	b7a080e7          	jalr	-1158(ra) # 5720 <open>
    4bae:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    4bb0:	4481                	li	s1,0
    memset(buf, i, SZ);
    4bb2:	00007917          	auipc	s2,0x7
    4bb6:	01e90913          	addi	s2,s2,30 # bbd0 <buf>
  for(i = 0; i < N; i++){
    4bba:	4a51                	li	s4,20
  if(fd < 0){
    4bbc:	0a054063          	bltz	a0,4c5c <bigfile+0xe6>
    memset(buf, i, SZ);
    4bc0:	25800613          	li	a2,600
    4bc4:	85a6                	mv	a1,s1
    4bc6:	854a                	mv	a0,s2
    4bc8:	00001097          	auipc	ra,0x1
    4bcc:	91c080e7          	jalr	-1764(ra) # 54e4 <memset>
    if(write(fd, buf, SZ) != SZ){
    4bd0:	25800613          	li	a2,600
    4bd4:	85ca                	mv	a1,s2
    4bd6:	854e                	mv	a0,s3
    4bd8:	00001097          	auipc	ra,0x1
    4bdc:	b28080e7          	jalr	-1240(ra) # 5700 <write>
    4be0:	25800793          	li	a5,600
    4be4:	08f51a63          	bne	a0,a5,4c78 <bigfile+0x102>
  for(i = 0; i < N; i++){
    4be8:	2485                	addiw	s1,s1,1
    4bea:	fd449be3          	bne	s1,s4,4bc0 <bigfile+0x4a>
  close(fd);
    4bee:	854e                	mv	a0,s3
    4bf0:	00001097          	auipc	ra,0x1
    4bf4:	b18080e7          	jalr	-1256(ra) # 5708 <close>
  fd = open("bigfile.dat", 0);
    4bf8:	4581                	li	a1,0
    4bfa:	00003517          	auipc	a0,0x3
    4bfe:	06e50513          	addi	a0,a0,110 # 7c68 <malloc+0x2152>
    4c02:	00001097          	auipc	ra,0x1
    4c06:	b1e080e7          	jalr	-1250(ra) # 5720 <open>
    4c0a:	8a2a                	mv	s4,a0
  total = 0;
    4c0c:	4981                	li	s3,0
  for(i = 0; ; i++){
    4c0e:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    4c10:	00007917          	auipc	s2,0x7
    4c14:	fc090913          	addi	s2,s2,-64 # bbd0 <buf>
  if(fd < 0){
    4c18:	06054e63          	bltz	a0,4c94 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    4c1c:	12c00613          	li	a2,300
    4c20:	85ca                	mv	a1,s2
    4c22:	8552                	mv	a0,s4
    4c24:	00001097          	auipc	ra,0x1
    4c28:	ad4080e7          	jalr	-1324(ra) # 56f8 <read>
    if(cc < 0){
    4c2c:	08054263          	bltz	a0,4cb0 <bigfile+0x13a>
    if(cc == 0)
    4c30:	c971                	beqz	a0,4d04 <bigfile+0x18e>
    if(cc != SZ/2){
    4c32:	12c00793          	li	a5,300
    4c36:	08f51b63          	bne	a0,a5,4ccc <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    4c3a:	01f4d79b          	srliw	a5,s1,0x1f
    4c3e:	9fa5                	addw	a5,a5,s1
    4c40:	4017d79b          	sraiw	a5,a5,0x1
    4c44:	00094703          	lbu	a4,0(s2)
    4c48:	0af71063          	bne	a4,a5,4ce8 <bigfile+0x172>
    4c4c:	12b94703          	lbu	a4,299(s2)
    4c50:	08f71c63          	bne	a4,a5,4ce8 <bigfile+0x172>
    total += cc;
    4c54:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    4c58:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    4c5a:	b7c9                	j	4c1c <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    4c5c:	85d6                	mv	a1,s5
    4c5e:	00003517          	auipc	a0,0x3
    4c62:	01a50513          	addi	a0,a0,26 # 7c78 <malloc+0x2162>
    4c66:	00001097          	auipc	ra,0x1
    4c6a:	df2080e7          	jalr	-526(ra) # 5a58 <printf>
    exit(1);
    4c6e:	4505                	li	a0,1
    4c70:	00001097          	auipc	ra,0x1
    4c74:	a70080e7          	jalr	-1424(ra) # 56e0 <exit>
      printf("%s: write bigfile failed\n", s);
    4c78:	85d6                	mv	a1,s5
    4c7a:	00003517          	auipc	a0,0x3
    4c7e:	01e50513          	addi	a0,a0,30 # 7c98 <malloc+0x2182>
    4c82:	00001097          	auipc	ra,0x1
    4c86:	dd6080e7          	jalr	-554(ra) # 5a58 <printf>
      exit(1);
    4c8a:	4505                	li	a0,1
    4c8c:	00001097          	auipc	ra,0x1
    4c90:	a54080e7          	jalr	-1452(ra) # 56e0 <exit>
    printf("%s: cannot open bigfile\n", s);
    4c94:	85d6                	mv	a1,s5
    4c96:	00003517          	auipc	a0,0x3
    4c9a:	02250513          	addi	a0,a0,34 # 7cb8 <malloc+0x21a2>
    4c9e:	00001097          	auipc	ra,0x1
    4ca2:	dba080e7          	jalr	-582(ra) # 5a58 <printf>
    exit(1);
    4ca6:	4505                	li	a0,1
    4ca8:	00001097          	auipc	ra,0x1
    4cac:	a38080e7          	jalr	-1480(ra) # 56e0 <exit>
      printf("%s: read bigfile failed\n", s);
    4cb0:	85d6                	mv	a1,s5
    4cb2:	00003517          	auipc	a0,0x3
    4cb6:	02650513          	addi	a0,a0,38 # 7cd8 <malloc+0x21c2>
    4cba:	00001097          	auipc	ra,0x1
    4cbe:	d9e080e7          	jalr	-610(ra) # 5a58 <printf>
      exit(1);
    4cc2:	4505                	li	a0,1
    4cc4:	00001097          	auipc	ra,0x1
    4cc8:	a1c080e7          	jalr	-1508(ra) # 56e0 <exit>
      printf("%s: short read bigfile\n", s);
    4ccc:	85d6                	mv	a1,s5
    4cce:	00003517          	auipc	a0,0x3
    4cd2:	02a50513          	addi	a0,a0,42 # 7cf8 <malloc+0x21e2>
    4cd6:	00001097          	auipc	ra,0x1
    4cda:	d82080e7          	jalr	-638(ra) # 5a58 <printf>
      exit(1);
    4cde:	4505                	li	a0,1
    4ce0:	00001097          	auipc	ra,0x1
    4ce4:	a00080e7          	jalr	-1536(ra) # 56e0 <exit>
      printf("%s: read bigfile wrong data\n", s);
    4ce8:	85d6                	mv	a1,s5
    4cea:	00003517          	auipc	a0,0x3
    4cee:	02650513          	addi	a0,a0,38 # 7d10 <malloc+0x21fa>
    4cf2:	00001097          	auipc	ra,0x1
    4cf6:	d66080e7          	jalr	-666(ra) # 5a58 <printf>
      exit(1);
    4cfa:	4505                	li	a0,1
    4cfc:	00001097          	auipc	ra,0x1
    4d00:	9e4080e7          	jalr	-1564(ra) # 56e0 <exit>
  close(fd);
    4d04:	8552                	mv	a0,s4
    4d06:	00001097          	auipc	ra,0x1
    4d0a:	a02080e7          	jalr	-1534(ra) # 5708 <close>
  if(total != N*SZ){
    4d0e:	678d                	lui	a5,0x3
    4d10:	ee078793          	addi	a5,a5,-288 # 2ee0 <exitiputtest+0x48>
    4d14:	02f99363          	bne	s3,a5,4d3a <bigfile+0x1c4>
  unlink("bigfile.dat");
    4d18:	00003517          	auipc	a0,0x3
    4d1c:	f5050513          	addi	a0,a0,-176 # 7c68 <malloc+0x2152>
    4d20:	00001097          	auipc	ra,0x1
    4d24:	a10080e7          	jalr	-1520(ra) # 5730 <unlink>
}
    4d28:	70e2                	ld	ra,56(sp)
    4d2a:	7442                	ld	s0,48(sp)
    4d2c:	74a2                	ld	s1,40(sp)
    4d2e:	7902                	ld	s2,32(sp)
    4d30:	69e2                	ld	s3,24(sp)
    4d32:	6a42                	ld	s4,16(sp)
    4d34:	6aa2                	ld	s5,8(sp)
    4d36:	6121                	addi	sp,sp,64
    4d38:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4d3a:	85d6                	mv	a1,s5
    4d3c:	00003517          	auipc	a0,0x3
    4d40:	ff450513          	addi	a0,a0,-12 # 7d30 <malloc+0x221a>
    4d44:	00001097          	auipc	ra,0x1
    4d48:	d14080e7          	jalr	-748(ra) # 5a58 <printf>
    exit(1);
    4d4c:	4505                	li	a0,1
    4d4e:	00001097          	auipc	ra,0x1
    4d52:	992080e7          	jalr	-1646(ra) # 56e0 <exit>

0000000000004d56 <fsfull>:
{
    4d56:	7171                	addi	sp,sp,-176
    4d58:	f506                	sd	ra,168(sp)
    4d5a:	f122                	sd	s0,160(sp)
    4d5c:	ed26                	sd	s1,152(sp)
    4d5e:	e94a                	sd	s2,144(sp)
    4d60:	e54e                	sd	s3,136(sp)
    4d62:	e152                	sd	s4,128(sp)
    4d64:	fcd6                	sd	s5,120(sp)
    4d66:	f8da                	sd	s6,112(sp)
    4d68:	f4de                	sd	s7,104(sp)
    4d6a:	f0e2                	sd	s8,96(sp)
    4d6c:	ece6                	sd	s9,88(sp)
    4d6e:	e8ea                	sd	s10,80(sp)
    4d70:	e4ee                	sd	s11,72(sp)
    4d72:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    4d74:	00003517          	auipc	a0,0x3
    4d78:	fdc50513          	addi	a0,a0,-36 # 7d50 <malloc+0x223a>
    4d7c:	00001097          	auipc	ra,0x1
    4d80:	cdc080e7          	jalr	-804(ra) # 5a58 <printf>
  for(nfiles = 0; ; nfiles++){
    4d84:	4481                	li	s1,0
    name[0] = 'f';
    4d86:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4d8a:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4d8e:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4d92:	4b29                	li	s6,10
    printf("writing %s\n", name);
    4d94:	00003c97          	auipc	s9,0x3
    4d98:	fccc8c93          	addi	s9,s9,-52 # 7d60 <malloc+0x224a>
    int total = 0;
    4d9c:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4d9e:	00007a17          	auipc	s4,0x7
    4da2:	e32a0a13          	addi	s4,s4,-462 # bbd0 <buf>
    name[0] = 'f';
    4da6:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4daa:	0384c7bb          	divw	a5,s1,s8
    4dae:	0307879b          	addiw	a5,a5,48
    4db2:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4db6:	0384e7bb          	remw	a5,s1,s8
    4dba:	0377c7bb          	divw	a5,a5,s7
    4dbe:	0307879b          	addiw	a5,a5,48
    4dc2:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4dc6:	0374e7bb          	remw	a5,s1,s7
    4dca:	0367c7bb          	divw	a5,a5,s6
    4dce:	0307879b          	addiw	a5,a5,48
    4dd2:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4dd6:	0364e7bb          	remw	a5,s1,s6
    4dda:	0307879b          	addiw	a5,a5,48
    4dde:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4de2:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    4de6:	f5040593          	addi	a1,s0,-176
    4dea:	8566                	mv	a0,s9
    4dec:	00001097          	auipc	ra,0x1
    4df0:	c6c080e7          	jalr	-916(ra) # 5a58 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4df4:	20200593          	li	a1,514
    4df8:	f5040513          	addi	a0,s0,-176
    4dfc:	00001097          	auipc	ra,0x1
    4e00:	924080e7          	jalr	-1756(ra) # 5720 <open>
    4e04:	892a                	mv	s2,a0
    if(fd < 0){
    4e06:	0a055663          	bgez	a0,4eb2 <fsfull+0x15c>
      printf("open %s failed\n", name);
    4e0a:	f5040593          	addi	a1,s0,-176
    4e0e:	00003517          	auipc	a0,0x3
    4e12:	f6250513          	addi	a0,a0,-158 # 7d70 <malloc+0x225a>
    4e16:	00001097          	auipc	ra,0x1
    4e1a:	c42080e7          	jalr	-958(ra) # 5a58 <printf>
  while(nfiles >= 0){
    4e1e:	0604c363          	bltz	s1,4e84 <fsfull+0x12e>
    name[0] = 'f';
    4e22:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4e26:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4e2a:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4e2e:	4929                	li	s2,10
  while(nfiles >= 0){
    4e30:	5afd                	li	s5,-1
    name[0] = 'f';
    4e32:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4e36:	0344c7bb          	divw	a5,s1,s4
    4e3a:	0307879b          	addiw	a5,a5,48
    4e3e:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4e42:	0344e7bb          	remw	a5,s1,s4
    4e46:	0337c7bb          	divw	a5,a5,s3
    4e4a:	0307879b          	addiw	a5,a5,48
    4e4e:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4e52:	0334e7bb          	remw	a5,s1,s3
    4e56:	0327c7bb          	divw	a5,a5,s2
    4e5a:	0307879b          	addiw	a5,a5,48
    4e5e:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4e62:	0324e7bb          	remw	a5,s1,s2
    4e66:	0307879b          	addiw	a5,a5,48
    4e6a:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4e6e:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    4e72:	f5040513          	addi	a0,s0,-176
    4e76:	00001097          	auipc	ra,0x1
    4e7a:	8ba080e7          	jalr	-1862(ra) # 5730 <unlink>
    nfiles--;
    4e7e:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4e80:	fb5499e3          	bne	s1,s5,4e32 <fsfull+0xdc>
  printf("fsfull test finished\n");
    4e84:	00003517          	auipc	a0,0x3
    4e88:	f0c50513          	addi	a0,a0,-244 # 7d90 <malloc+0x227a>
    4e8c:	00001097          	auipc	ra,0x1
    4e90:	bcc080e7          	jalr	-1076(ra) # 5a58 <printf>
}
    4e94:	70aa                	ld	ra,168(sp)
    4e96:	740a                	ld	s0,160(sp)
    4e98:	64ea                	ld	s1,152(sp)
    4e9a:	694a                	ld	s2,144(sp)
    4e9c:	69aa                	ld	s3,136(sp)
    4e9e:	6a0a                	ld	s4,128(sp)
    4ea0:	7ae6                	ld	s5,120(sp)
    4ea2:	7b46                	ld	s6,112(sp)
    4ea4:	7ba6                	ld	s7,104(sp)
    4ea6:	7c06                	ld	s8,96(sp)
    4ea8:	6ce6                	ld	s9,88(sp)
    4eaa:	6d46                	ld	s10,80(sp)
    4eac:	6da6                	ld	s11,72(sp)
    4eae:	614d                	addi	sp,sp,176
    4eb0:	8082                	ret
    int total = 0;
    4eb2:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    4eb4:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4eb8:	40000613          	li	a2,1024
    4ebc:	85d2                	mv	a1,s4
    4ebe:	854a                	mv	a0,s2
    4ec0:	00001097          	auipc	ra,0x1
    4ec4:	840080e7          	jalr	-1984(ra) # 5700 <write>
      if(cc < BSIZE)
    4ec8:	00aad563          	bge	s5,a0,4ed2 <fsfull+0x17c>
      total += cc;
    4ecc:	00a989bb          	addw	s3,s3,a0
    while(1){
    4ed0:	b7e5                	j	4eb8 <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    4ed2:	85ce                	mv	a1,s3
    4ed4:	00003517          	auipc	a0,0x3
    4ed8:	eac50513          	addi	a0,a0,-340 # 7d80 <malloc+0x226a>
    4edc:	00001097          	auipc	ra,0x1
    4ee0:	b7c080e7          	jalr	-1156(ra) # 5a58 <printf>
    close(fd);
    4ee4:	854a                	mv	a0,s2
    4ee6:	00001097          	auipc	ra,0x1
    4eea:	822080e7          	jalr	-2014(ra) # 5708 <close>
    if(total == 0)
    4eee:	f20988e3          	beqz	s3,4e1e <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    4ef2:	2485                	addiw	s1,s1,1
    4ef4:	bd4d                	j	4da6 <fsfull+0x50>

0000000000004ef6 <rand>:
{
    4ef6:	1141                	addi	sp,sp,-16
    4ef8:	e422                	sd	s0,8(sp)
    4efa:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    4efc:	00003717          	auipc	a4,0x3
    4f00:	4ac70713          	addi	a4,a4,1196 # 83a8 <randstate>
    4f04:	6308                	ld	a0,0(a4)
    4f06:	001967b7          	lui	a5,0x196
    4f0a:	60d78793          	addi	a5,a5,1549 # 19660d <__BSS_END__+0x187a2d>
    4f0e:	02f50533          	mul	a0,a0,a5
    4f12:	3c6ef7b7          	lui	a5,0x3c6ef
    4f16:	35f78793          	addi	a5,a5,863 # 3c6ef35f <__BSS_END__+0x3c6e077f>
    4f1a:	953e                	add	a0,a0,a5
    4f1c:	e308                	sd	a0,0(a4)
}
    4f1e:	2501                	sext.w	a0,a0
    4f20:	6422                	ld	s0,8(sp)
    4f22:	0141                	addi	sp,sp,16
    4f24:	8082                	ret

0000000000004f26 <badwrite>:
{
    4f26:	7179                	addi	sp,sp,-48
    4f28:	f406                	sd	ra,40(sp)
    4f2a:	f022                	sd	s0,32(sp)
    4f2c:	ec26                	sd	s1,24(sp)
    4f2e:	e84a                	sd	s2,16(sp)
    4f30:	e44e                	sd	s3,8(sp)
    4f32:	e052                	sd	s4,0(sp)
    4f34:	1800                	addi	s0,sp,48
  unlink("junk");
    4f36:	00003517          	auipc	a0,0x3
    4f3a:	e7250513          	addi	a0,a0,-398 # 7da8 <malloc+0x2292>
    4f3e:	00000097          	auipc	ra,0x0
    4f42:	7f2080e7          	jalr	2034(ra) # 5730 <unlink>
    4f46:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    4f4a:	00003997          	auipc	s3,0x3
    4f4e:	e5e98993          	addi	s3,s3,-418 # 7da8 <malloc+0x2292>
    write(fd, (char*)0xffffffffffL, 1);
    4f52:	5a7d                	li	s4,-1
    4f54:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    4f58:	20100593          	li	a1,513
    4f5c:	854e                	mv	a0,s3
    4f5e:	00000097          	auipc	ra,0x0
    4f62:	7c2080e7          	jalr	1986(ra) # 5720 <open>
    4f66:	84aa                	mv	s1,a0
    if(fd < 0){
    4f68:	06054b63          	bltz	a0,4fde <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    4f6c:	4605                	li	a2,1
    4f6e:	85d2                	mv	a1,s4
    4f70:	00000097          	auipc	ra,0x0
    4f74:	790080e7          	jalr	1936(ra) # 5700 <write>
    close(fd);
    4f78:	8526                	mv	a0,s1
    4f7a:	00000097          	auipc	ra,0x0
    4f7e:	78e080e7          	jalr	1934(ra) # 5708 <close>
    unlink("junk");
    4f82:	854e                	mv	a0,s3
    4f84:	00000097          	auipc	ra,0x0
    4f88:	7ac080e7          	jalr	1964(ra) # 5730 <unlink>
  for(int i = 0; i < assumed_free; i++){
    4f8c:	397d                	addiw	s2,s2,-1
    4f8e:	fc0915e3          	bnez	s2,4f58 <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    4f92:	20100593          	li	a1,513
    4f96:	00003517          	auipc	a0,0x3
    4f9a:	e1250513          	addi	a0,a0,-494 # 7da8 <malloc+0x2292>
    4f9e:	00000097          	auipc	ra,0x0
    4fa2:	782080e7          	jalr	1922(ra) # 5720 <open>
    4fa6:	84aa                	mv	s1,a0
  if(fd < 0){
    4fa8:	04054863          	bltz	a0,4ff8 <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    4fac:	4605                	li	a2,1
    4fae:	00001597          	auipc	a1,0x1
    4fb2:	02a58593          	addi	a1,a1,42 # 5fd8 <malloc+0x4c2>
    4fb6:	00000097          	auipc	ra,0x0
    4fba:	74a080e7          	jalr	1866(ra) # 5700 <write>
    4fbe:	4785                	li	a5,1
    4fc0:	04f50963          	beq	a0,a5,5012 <badwrite+0xec>
    printf("write failed\n");
    4fc4:	00003517          	auipc	a0,0x3
    4fc8:	e0450513          	addi	a0,a0,-508 # 7dc8 <malloc+0x22b2>
    4fcc:	00001097          	auipc	ra,0x1
    4fd0:	a8c080e7          	jalr	-1396(ra) # 5a58 <printf>
    exit(1);
    4fd4:	4505                	li	a0,1
    4fd6:	00000097          	auipc	ra,0x0
    4fda:	70a080e7          	jalr	1802(ra) # 56e0 <exit>
      printf("open junk failed\n");
    4fde:	00003517          	auipc	a0,0x3
    4fe2:	dd250513          	addi	a0,a0,-558 # 7db0 <malloc+0x229a>
    4fe6:	00001097          	auipc	ra,0x1
    4fea:	a72080e7          	jalr	-1422(ra) # 5a58 <printf>
      exit(1);
    4fee:	4505                	li	a0,1
    4ff0:	00000097          	auipc	ra,0x0
    4ff4:	6f0080e7          	jalr	1776(ra) # 56e0 <exit>
    printf("open junk failed\n");
    4ff8:	00003517          	auipc	a0,0x3
    4ffc:	db850513          	addi	a0,a0,-584 # 7db0 <malloc+0x229a>
    5000:	00001097          	auipc	ra,0x1
    5004:	a58080e7          	jalr	-1448(ra) # 5a58 <printf>
    exit(1);
    5008:	4505                	li	a0,1
    500a:	00000097          	auipc	ra,0x0
    500e:	6d6080e7          	jalr	1750(ra) # 56e0 <exit>
  close(fd);
    5012:	8526                	mv	a0,s1
    5014:	00000097          	auipc	ra,0x0
    5018:	6f4080e7          	jalr	1780(ra) # 5708 <close>
  unlink("junk");
    501c:	00003517          	auipc	a0,0x3
    5020:	d8c50513          	addi	a0,a0,-628 # 7da8 <malloc+0x2292>
    5024:	00000097          	auipc	ra,0x0
    5028:	70c080e7          	jalr	1804(ra) # 5730 <unlink>
  exit(0);
    502c:	4501                	li	a0,0
    502e:	00000097          	auipc	ra,0x0
    5032:	6b2080e7          	jalr	1714(ra) # 56e0 <exit>

0000000000005036 <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    5036:	7139                	addi	sp,sp,-64
    5038:	fc06                	sd	ra,56(sp)
    503a:	f822                	sd	s0,48(sp)
    503c:	f426                	sd	s1,40(sp)
    503e:	f04a                	sd	s2,32(sp)
    5040:	ec4e                	sd	s3,24(sp)
    5042:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    5044:	fc840513          	addi	a0,s0,-56
    5048:	00000097          	auipc	ra,0x0
    504c:	6a8080e7          	jalr	1704(ra) # 56f0 <pipe>
    5050:	06054763          	bltz	a0,50be <countfree+0x88>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }

  int pid = fork();
    5054:	00000097          	auipc	ra,0x0
    5058:	684080e7          	jalr	1668(ra) # 56d8 <fork>

  if(pid < 0){
    505c:	06054e63          	bltz	a0,50d8 <countfree+0xa2>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    5060:	ed51                	bnez	a0,50fc <countfree+0xc6>
    close(fds[0]);
    5062:	fc842503          	lw	a0,-56(s0)
    5066:	00000097          	auipc	ra,0x0
    506a:	6a2080e7          	jalr	1698(ra) # 5708 <close>

    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    506e:	597d                	li	s2,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    5070:	4485                	li	s1,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    5072:	00001997          	auipc	s3,0x1
    5076:	f6698993          	addi	s3,s3,-154 # 5fd8 <malloc+0x4c2>
      uint64 a = (uint64) sbrk(4096);
    507a:	6505                	lui	a0,0x1
    507c:	00000097          	auipc	ra,0x0
    5080:	6ec080e7          	jalr	1772(ra) # 5768 <sbrk>
      if(a == 0xffffffffffffffff){
    5084:	07250763          	beq	a0,s2,50f2 <countfree+0xbc>
      *(char *)(a + 4096 - 1) = 1;
    5088:	6785                	lui	a5,0x1
    508a:	953e                	add	a0,a0,a5
    508c:	fe950fa3          	sb	s1,-1(a0) # fff <bigdir+0x9d>
      if(write(fds[1], "x", 1) != 1){
    5090:	8626                	mv	a2,s1
    5092:	85ce                	mv	a1,s3
    5094:	fcc42503          	lw	a0,-52(s0)
    5098:	00000097          	auipc	ra,0x0
    509c:	668080e7          	jalr	1640(ra) # 5700 <write>
    50a0:	fc950de3          	beq	a0,s1,507a <countfree+0x44>
        printf("write() failed in countfree()\n");
    50a4:	00003517          	auipc	a0,0x3
    50a8:	d7450513          	addi	a0,a0,-652 # 7e18 <malloc+0x2302>
    50ac:	00001097          	auipc	ra,0x1
    50b0:	9ac080e7          	jalr	-1620(ra) # 5a58 <printf>
        exit(1);
    50b4:	4505                	li	a0,1
    50b6:	00000097          	auipc	ra,0x0
    50ba:	62a080e7          	jalr	1578(ra) # 56e0 <exit>
    printf("pipe() failed in countfree()\n");
    50be:	00003517          	auipc	a0,0x3
    50c2:	d1a50513          	addi	a0,a0,-742 # 7dd8 <malloc+0x22c2>
    50c6:	00001097          	auipc	ra,0x1
    50ca:	992080e7          	jalr	-1646(ra) # 5a58 <printf>
    exit(1);
    50ce:	4505                	li	a0,1
    50d0:	00000097          	auipc	ra,0x0
    50d4:	610080e7          	jalr	1552(ra) # 56e0 <exit>
    printf("fork failed in countfree()\n");
    50d8:	00003517          	auipc	a0,0x3
    50dc:	d2050513          	addi	a0,a0,-736 # 7df8 <malloc+0x22e2>
    50e0:	00001097          	auipc	ra,0x1
    50e4:	978080e7          	jalr	-1672(ra) # 5a58 <printf>
    exit(1);
    50e8:	4505                	li	a0,1
    50ea:	00000097          	auipc	ra,0x0
    50ee:	5f6080e7          	jalr	1526(ra) # 56e0 <exit>
      }
    }

    exit(0);
    50f2:	4501                	li	a0,0
    50f4:	00000097          	auipc	ra,0x0
    50f8:	5ec080e7          	jalr	1516(ra) # 56e0 <exit>
  }

  close(fds[1]);
    50fc:	fcc42503          	lw	a0,-52(s0)
    5100:	00000097          	auipc	ra,0x0
    5104:	608080e7          	jalr	1544(ra) # 5708 <close>

  int n = 0;
    5108:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    510a:	4605                	li	a2,1
    510c:	fc740593          	addi	a1,s0,-57
    5110:	fc842503          	lw	a0,-56(s0)
    5114:	00000097          	auipc	ra,0x0
    5118:	5e4080e7          	jalr	1508(ra) # 56f8 <read>
    if(cc < 0){
    511c:	00054563          	bltz	a0,5126 <countfree+0xf0>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    5120:	c105                	beqz	a0,5140 <countfree+0x10a>
      break;
    n += 1;
    5122:	2485                	addiw	s1,s1,1
  while(1){
    5124:	b7dd                	j	510a <countfree+0xd4>
      printf("read() failed in countfree()\n");
    5126:	00003517          	auipc	a0,0x3
    512a:	d1250513          	addi	a0,a0,-750 # 7e38 <malloc+0x2322>
    512e:	00001097          	auipc	ra,0x1
    5132:	92a080e7          	jalr	-1750(ra) # 5a58 <printf>
      exit(1);
    5136:	4505                	li	a0,1
    5138:	00000097          	auipc	ra,0x0
    513c:	5a8080e7          	jalr	1448(ra) # 56e0 <exit>
  }

  close(fds[0]);
    5140:	fc842503          	lw	a0,-56(s0)
    5144:	00000097          	auipc	ra,0x0
    5148:	5c4080e7          	jalr	1476(ra) # 5708 <close>
  wait((int*)0);
    514c:	4501                	li	a0,0
    514e:	00000097          	auipc	ra,0x0
    5152:	59a080e7          	jalr	1434(ra) # 56e8 <wait>

  return n;
}
    5156:	8526                	mv	a0,s1
    5158:	70e2                	ld	ra,56(sp)
    515a:	7442                	ld	s0,48(sp)
    515c:	74a2                	ld	s1,40(sp)
    515e:	7902                	ld	s2,32(sp)
    5160:	69e2                	ld	s3,24(sp)
    5162:	6121                	addi	sp,sp,64
    5164:	8082                	ret

0000000000005166 <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    5166:	7179                	addi	sp,sp,-48
    5168:	f406                	sd	ra,40(sp)
    516a:	f022                	sd	s0,32(sp)
    516c:	ec26                	sd	s1,24(sp)
    516e:	e84a                	sd	s2,16(sp)
    5170:	1800                	addi	s0,sp,48
    5172:	84aa                	mv	s1,a0
    5174:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    5176:	00003517          	auipc	a0,0x3
    517a:	ce250513          	addi	a0,a0,-798 # 7e58 <malloc+0x2342>
    517e:	00001097          	auipc	ra,0x1
    5182:	8da080e7          	jalr	-1830(ra) # 5a58 <printf>
  if((pid = fork()) < 0) {
    5186:	00000097          	auipc	ra,0x0
    518a:	552080e7          	jalr	1362(ra) # 56d8 <fork>
    518e:	02054e63          	bltz	a0,51ca <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    5192:	c929                	beqz	a0,51e4 <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    5194:	fdc40513          	addi	a0,s0,-36
    5198:	00000097          	auipc	ra,0x0
    519c:	550080e7          	jalr	1360(ra) # 56e8 <wait>
    if(xstatus != 0)
    51a0:	fdc42783          	lw	a5,-36(s0)
    51a4:	c7b9                	beqz	a5,51f2 <run+0x8c>
      printf("FAILED\n");
    51a6:	00003517          	auipc	a0,0x3
    51aa:	cda50513          	addi	a0,a0,-806 # 7e80 <malloc+0x236a>
    51ae:	00001097          	auipc	ra,0x1
    51b2:	8aa080e7          	jalr	-1878(ra) # 5a58 <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    51b6:	fdc42503          	lw	a0,-36(s0)
  }
}
    51ba:	00153513          	seqz	a0,a0
    51be:	70a2                	ld	ra,40(sp)
    51c0:	7402                	ld	s0,32(sp)
    51c2:	64e2                	ld	s1,24(sp)
    51c4:	6942                	ld	s2,16(sp)
    51c6:	6145                	addi	sp,sp,48
    51c8:	8082                	ret
    printf("runtest: fork error\n");
    51ca:	00003517          	auipc	a0,0x3
    51ce:	c9e50513          	addi	a0,a0,-866 # 7e68 <malloc+0x2352>
    51d2:	00001097          	auipc	ra,0x1
    51d6:	886080e7          	jalr	-1914(ra) # 5a58 <printf>
    exit(1);
    51da:	4505                	li	a0,1
    51dc:	00000097          	auipc	ra,0x0
    51e0:	504080e7          	jalr	1284(ra) # 56e0 <exit>
    f(s);
    51e4:	854a                	mv	a0,s2
    51e6:	9482                	jalr	s1
    exit(0);
    51e8:	4501                	li	a0,0
    51ea:	00000097          	auipc	ra,0x0
    51ee:	4f6080e7          	jalr	1270(ra) # 56e0 <exit>
      printf("OK\n");
    51f2:	00003517          	auipc	a0,0x3
    51f6:	c9650513          	addi	a0,a0,-874 # 7e88 <malloc+0x2372>
    51fa:	00001097          	auipc	ra,0x1
    51fe:	85e080e7          	jalr	-1954(ra) # 5a58 <printf>
    5202:	bf55                	j	51b6 <run+0x50>

0000000000005204 <main>:

int
main(int argc, char *argv[])
{
    5204:	c0010113          	addi	sp,sp,-1024
    5208:	3e113c23          	sd	ra,1016(sp)
    520c:	3e813823          	sd	s0,1008(sp)
    5210:	3e913423          	sd	s1,1000(sp)
    5214:	3f213023          	sd	s2,992(sp)
    5218:	3d313c23          	sd	s3,984(sp)
    521c:	3d413823          	sd	s4,976(sp)
    5220:	3d513423          	sd	s5,968(sp)
    5224:	3d613023          	sd	s6,960(sp)
    5228:	40010413          	addi	s0,sp,1024
    522c:	89aa                	mv	s3,a0
    522e:	84ae                	mv	s1,a1
printf("ut 2\n");
    5230:	00003517          	auipc	a0,0x3
    5234:	c6050513          	addi	a0,a0,-928 # 7e90 <malloc+0x237a>
    5238:	00001097          	auipc	ra,0x1
    523c:	820080e7          	jalr	-2016(ra) # 5a58 <printf>

  int continuous = 0;
  char *justone = 0;
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5240:	4789                	li	a5,2
    5242:	0af98063          	beq	s3,a5,52e2 <main+0xde>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    5246:	4785                	li	a5,1
  char *justone = 0;
    5248:	4901                	li	s2,0
  } else if(argc > 1){
    524a:	0d37c863          	blt	a5,s3,531a <main+0x116>
    printf("Usage: usertests [-c] [testname]\n");
    exit(1);
  }
  printf("ut 1\n");
    524e:	00003517          	auipc	a0,0x3
    5252:	d0a50513          	addi	a0,a0,-758 # 7f58 <malloc+0x2442>
    5256:	00001097          	auipc	ra,0x1
    525a:	802080e7          	jalr	-2046(ra) # 5a58 <printf>
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    525e:	00003797          	auipc	a5,0x3
    5262:	d6278793          	addi	a5,a5,-670 # 7fc0 <malloc+0x24aa>
    5266:	c0040713          	addi	a4,s0,-1024
    526a:	00003817          	auipc	a6,0x3
    526e:	11680813          	addi	a6,a6,278 # 8380 <malloc+0x286a>
    5272:	6388                	ld	a0,0(a5)
    5274:	678c                	ld	a1,8(a5)
    5276:	6b90                	ld	a2,16(a5)
    5278:	6f94                	ld	a3,24(a5)
    527a:	e308                	sd	a0,0(a4)
    527c:	e70c                	sd	a1,8(a4)
    527e:	eb10                	sd	a2,16(a4)
    5280:	ef14                	sd	a3,24(a4)
    5282:	02078793          	addi	a5,a5,32
    5286:	02070713          	addi	a4,a4,32
    528a:	ff0794e3          	bne	a5,a6,5272 <main+0x6e>
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    528e:	00003517          	auipc	a0,0x3
    5292:	cd250513          	addi	a0,a0,-814 # 7f60 <malloc+0x244a>
    5296:	00000097          	auipc	ra,0x0
    529a:	7c2080e7          	jalr	1986(ra) # 5a58 <printf>
  int free0 = countfree();
    529e:	00000097          	auipc	ra,0x0
    52a2:	d98080e7          	jalr	-616(ra) # 5036 <countfree>
    52a6:	8a2a                	mv	s4,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    52a8:	c0843503          	ld	a0,-1016(s0)
    52ac:	c0040493          	addi	s1,s0,-1024
  int fail = 0;
    52b0:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    52b2:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    52b4:	12051163          	bnez	a0,53d6 <main+0x1d2>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    52b8:	00000097          	auipc	ra,0x0
    52bc:	d7e080e7          	jalr	-642(ra) # 5036 <countfree>
    52c0:	85aa                	mv	a1,a0
    52c2:	15455a63          	bge	a0,s4,5416 <main+0x212>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    52c6:	8652                	mv	a2,s4
    52c8:	00003517          	auipc	a0,0x3
    52cc:	c4850513          	addi	a0,a0,-952 # 7f10 <malloc+0x23fa>
    52d0:	00000097          	auipc	ra,0x0
    52d4:	788080e7          	jalr	1928(ra) # 5a58 <printf>
    exit(1);
    52d8:	4505                	li	a0,1
    52da:	00000097          	auipc	ra,0x0
    52de:	406080e7          	jalr	1030(ra) # 56e0 <exit>
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    52e2:	00003597          	auipc	a1,0x3
    52e6:	bb658593          	addi	a1,a1,-1098 # 7e98 <malloc+0x2382>
    52ea:	6488                	ld	a0,8(s1)
    52ec:	00000097          	auipc	ra,0x0
    52f0:	1a2080e7          	jalr	418(ra) # 548e <strcmp>
    52f4:	c121                	beqz	a0,5334 <main+0x130>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    52f6:	00003597          	auipc	a1,0x3
    52fa:	ca258593          	addi	a1,a1,-862 # 7f98 <malloc+0x2482>
    52fe:	6488                	ld	a0,8(s1)
    5300:	00000097          	auipc	ra,0x0
    5304:	18e080e7          	jalr	398(ra) # 548e <strcmp>
    5308:	cd1d                	beqz	a0,5346 <main+0x142>
  } else if(argc == 2 && argv[1][0] != '-'){
    530a:	0084b903          	ld	s2,8(s1)
    530e:	00094703          	lbu	a4,0(s2)
    5312:	02d00793          	li	a5,45
    5316:	f2f71ce3          	bne	a4,a5,524e <main+0x4a>
    printf("Usage: usertests [-c] [testname]\n");
    531a:	00003517          	auipc	a0,0x3
    531e:	b9650513          	addi	a0,a0,-1130 # 7eb0 <malloc+0x239a>
    5322:	00000097          	auipc	ra,0x0
    5326:	736080e7          	jalr	1846(ra) # 5a58 <printf>
    exit(1);
    532a:	4505                	li	a0,1
    532c:	00000097          	auipc	ra,0x0
    5330:	3b4080e7          	jalr	948(ra) # 56e0 <exit>
    printf("continuous = 1");
    5334:	00003517          	auipc	a0,0x3
    5338:	b6c50513          	addi	a0,a0,-1172 # 7ea0 <malloc+0x238a>
    533c:	00000097          	auipc	ra,0x0
    5340:	71c080e7          	jalr	1820(ra) # 5a58 <printf>
    continuous = 1;
    5344:	4985                	li	s3,1
  printf("ut 1\n");
    5346:	00003517          	auipc	a0,0x3
    534a:	c1250513          	addi	a0,a0,-1006 # 7f58 <malloc+0x2442>
    534e:	00000097          	auipc	ra,0x0
    5352:	70a080e7          	jalr	1802(ra) # 5a58 <printf>
  } tests[] = {
    5356:	00003797          	auipc	a5,0x3
    535a:	c6a78793          	addi	a5,a5,-918 # 7fc0 <malloc+0x24aa>
    535e:	c0040713          	addi	a4,s0,-1024
    5362:	00003817          	auipc	a6,0x3
    5366:	01e80813          	addi	a6,a6,30 # 8380 <malloc+0x286a>
    536a:	6388                	ld	a0,0(a5)
    536c:	678c                	ld	a1,8(a5)
    536e:	6b90                	ld	a2,16(a5)
    5370:	6f94                	ld	a3,24(a5)
    5372:	e308                	sd	a0,0(a4)
    5374:	e70c                	sd	a1,8(a4)
    5376:	eb10                	sd	a2,16(a4)
    5378:	ef14                	sd	a3,24(a4)
    537a:	02078793          	addi	a5,a5,32
    537e:	02070713          	addi	a4,a4,32
    5382:	ff0794e3          	bne	a5,a6,536a <main+0x166>
    printf("continuous usertests starting\n");
    5386:	00003517          	auipc	a0,0x3
    538a:	bf250513          	addi	a0,a0,-1038 # 7f78 <malloc+0x2462>
    538e:	00000097          	auipc	ra,0x0
    5392:	6ca080e7          	jalr	1738(ra) # 5a58 <printf>
        printf("SOME TESTS FAILED\n");
    5396:	00003a97          	auipc	s5,0x3
    539a:	b62a8a93          	addi	s5,s5,-1182 # 7ef8 <malloc+0x23e2>
        if(continuous != 2)
    539e:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    53a0:	00003b17          	auipc	s6,0x3
    53a4:	b38b0b13          	addi	s6,s6,-1224 # 7ed8 <malloc+0x23c2>
    53a8:	a04d                	j	544a <main+0x246>
          exit(1);
    53aa:	4505                	li	a0,1
    53ac:	00000097          	auipc	ra,0x0
    53b0:	334080e7          	jalr	820(ra) # 56e0 <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    53b4:	40a905bb          	subw	a1,s2,a0
    53b8:	855a                	mv	a0,s6
    53ba:	00000097          	auipc	ra,0x0
    53be:	69e080e7          	jalr	1694(ra) # 5a58 <printf>
        if(continuous != 2)
    53c2:	09498463          	beq	s3,s4,544a <main+0x246>
          exit(1);
    53c6:	4505                	li	a0,1
    53c8:	00000097          	auipc	ra,0x0
    53cc:	318080e7          	jalr	792(ra) # 56e0 <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    53d0:	04c1                	addi	s1,s1,16
    53d2:	6488                	ld	a0,8(s1)
    53d4:	c115                	beqz	a0,53f8 <main+0x1f4>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    53d6:	00090863          	beqz	s2,53e6 <main+0x1e2>
    53da:	85ca                	mv	a1,s2
    53dc:	00000097          	auipc	ra,0x0
    53e0:	0b2080e7          	jalr	178(ra) # 548e <strcmp>
    53e4:	f575                	bnez	a0,53d0 <main+0x1cc>
      if(!run(t->f, t->s))
    53e6:	648c                	ld	a1,8(s1)
    53e8:	6088                	ld	a0,0(s1)
    53ea:	00000097          	auipc	ra,0x0
    53ee:	d7c080e7          	jalr	-644(ra) # 5166 <run>
    53f2:	fd79                	bnez	a0,53d0 <main+0x1cc>
        fail = 1;
    53f4:	89d6                	mv	s3,s5
    53f6:	bfe9                	j	53d0 <main+0x1cc>
  if(fail){
    53f8:	ec0980e3          	beqz	s3,52b8 <main+0xb4>
    printf("SOME TESTS FAILED\n");
    53fc:	00003517          	auipc	a0,0x3
    5400:	afc50513          	addi	a0,a0,-1284 # 7ef8 <malloc+0x23e2>
    5404:	00000097          	auipc	ra,0x0
    5408:	654080e7          	jalr	1620(ra) # 5a58 <printf>
    exit(1);
    540c:	4505                	li	a0,1
    540e:	00000097          	auipc	ra,0x0
    5412:	2d2080e7          	jalr	722(ra) # 56e0 <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    5416:	00003517          	auipc	a0,0x3
    541a:	b2a50513          	addi	a0,a0,-1238 # 7f40 <malloc+0x242a>
    541e:	00000097          	auipc	ra,0x0
    5422:	63a080e7          	jalr	1594(ra) # 5a58 <printf>
    exit(0);
    5426:	4501                	li	a0,0
    5428:	00000097          	auipc	ra,0x0
    542c:	2b8080e7          	jalr	696(ra) # 56e0 <exit>
        printf("SOME TESTS FAILED\n");
    5430:	8556                	mv	a0,s5
    5432:	00000097          	auipc	ra,0x0
    5436:	626080e7          	jalr	1574(ra) # 5a58 <printf>
        if(continuous != 2)
    543a:	f74998e3          	bne	s3,s4,53aa <main+0x1a6>
      int free1 = countfree();
    543e:	00000097          	auipc	ra,0x0
    5442:	bf8080e7          	jalr	-1032(ra) # 5036 <countfree>
      if(free1 < free0){
    5446:	f72547e3          	blt	a0,s2,53b4 <main+0x1b0>
      int free0 = countfree();
    544a:	00000097          	auipc	ra,0x0
    544e:	bec080e7          	jalr	-1044(ra) # 5036 <countfree>
    5452:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    5454:	c0843583          	ld	a1,-1016(s0)
    5458:	d1fd                	beqz	a1,543e <main+0x23a>
    545a:	c0040493          	addi	s1,s0,-1024
        if(!run(t->f, t->s)){
    545e:	6088                	ld	a0,0(s1)
    5460:	00000097          	auipc	ra,0x0
    5464:	d06080e7          	jalr	-762(ra) # 5166 <run>
    5468:	d561                	beqz	a0,5430 <main+0x22c>
      for (struct test *t = tests; t->s != 0; t++) {
    546a:	04c1                	addi	s1,s1,16
    546c:	648c                	ld	a1,8(s1)
    546e:	f9e5                	bnez	a1,545e <main+0x25a>
    5470:	b7f9                	j	543e <main+0x23a>

0000000000005472 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    5472:	1141                	addi	sp,sp,-16
    5474:	e422                	sd	s0,8(sp)
    5476:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    5478:	87aa                	mv	a5,a0
    547a:	0585                	addi	a1,a1,1
    547c:	0785                	addi	a5,a5,1
    547e:	fff5c703          	lbu	a4,-1(a1)
    5482:	fee78fa3          	sb	a4,-1(a5)
    5486:	fb75                	bnez	a4,547a <strcpy+0x8>
    ;
  return os;
}
    5488:	6422                	ld	s0,8(sp)
    548a:	0141                	addi	sp,sp,16
    548c:	8082                	ret

000000000000548e <strcmp>:

int
strcmp(const char *p, const char *q)
{
    548e:	1141                	addi	sp,sp,-16
    5490:	e422                	sd	s0,8(sp)
    5492:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    5494:	00054783          	lbu	a5,0(a0)
    5498:	cb91                	beqz	a5,54ac <strcmp+0x1e>
    549a:	0005c703          	lbu	a4,0(a1)
    549e:	00f71763          	bne	a4,a5,54ac <strcmp+0x1e>
    p++, q++;
    54a2:	0505                	addi	a0,a0,1
    54a4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    54a6:	00054783          	lbu	a5,0(a0)
    54aa:	fbe5                	bnez	a5,549a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    54ac:	0005c503          	lbu	a0,0(a1)
}
    54b0:	40a7853b          	subw	a0,a5,a0
    54b4:	6422                	ld	s0,8(sp)
    54b6:	0141                	addi	sp,sp,16
    54b8:	8082                	ret

00000000000054ba <strlen>:

uint
strlen(const char *s)
{
    54ba:	1141                	addi	sp,sp,-16
    54bc:	e422                	sd	s0,8(sp)
    54be:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    54c0:	00054783          	lbu	a5,0(a0)
    54c4:	cf91                	beqz	a5,54e0 <strlen+0x26>
    54c6:	0505                	addi	a0,a0,1
    54c8:	87aa                	mv	a5,a0
    54ca:	4685                	li	a3,1
    54cc:	9e89                	subw	a3,a3,a0
    54ce:	00f6853b          	addw	a0,a3,a5
    54d2:	0785                	addi	a5,a5,1
    54d4:	fff7c703          	lbu	a4,-1(a5)
    54d8:	fb7d                	bnez	a4,54ce <strlen+0x14>
    ;
  return n;
}
    54da:	6422                	ld	s0,8(sp)
    54dc:	0141                	addi	sp,sp,16
    54de:	8082                	ret
  for(n = 0; s[n]; n++)
    54e0:	4501                	li	a0,0
    54e2:	bfe5                	j	54da <strlen+0x20>

00000000000054e4 <memset>:

void*
memset(void *dst, int c, uint n)
{
    54e4:	1141                	addi	sp,sp,-16
    54e6:	e422                	sd	s0,8(sp)
    54e8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    54ea:	ca19                	beqz	a2,5500 <memset+0x1c>
    54ec:	87aa                	mv	a5,a0
    54ee:	1602                	slli	a2,a2,0x20
    54f0:	9201                	srli	a2,a2,0x20
    54f2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    54f6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    54fa:	0785                	addi	a5,a5,1
    54fc:	fee79de3          	bne	a5,a4,54f6 <memset+0x12>
  }
  return dst;
}
    5500:	6422                	ld	s0,8(sp)
    5502:	0141                	addi	sp,sp,16
    5504:	8082                	ret

0000000000005506 <strchr>:

char*
strchr(const char *s, char c)
{
    5506:	1141                	addi	sp,sp,-16
    5508:	e422                	sd	s0,8(sp)
    550a:	0800                	addi	s0,sp,16
  for(; *s; s++)
    550c:	00054783          	lbu	a5,0(a0)
    5510:	cb99                	beqz	a5,5526 <strchr+0x20>
    if(*s == c)
    5512:	00f58763          	beq	a1,a5,5520 <strchr+0x1a>
  for(; *s; s++)
    5516:	0505                	addi	a0,a0,1
    5518:	00054783          	lbu	a5,0(a0)
    551c:	fbfd                	bnez	a5,5512 <strchr+0xc>
      return (char*)s;
  return 0;
    551e:	4501                	li	a0,0
}
    5520:	6422                	ld	s0,8(sp)
    5522:	0141                	addi	sp,sp,16
    5524:	8082                	ret
  return 0;
    5526:	4501                	li	a0,0
    5528:	bfe5                	j	5520 <strchr+0x1a>

000000000000552a <gets>:

char*
gets(char *buf, int max)
{
    552a:	711d                	addi	sp,sp,-96
    552c:	ec86                	sd	ra,88(sp)
    552e:	e8a2                	sd	s0,80(sp)
    5530:	e4a6                	sd	s1,72(sp)
    5532:	e0ca                	sd	s2,64(sp)
    5534:	fc4e                	sd	s3,56(sp)
    5536:	f852                	sd	s4,48(sp)
    5538:	f456                	sd	s5,40(sp)
    553a:	f05a                	sd	s6,32(sp)
    553c:	ec5e                	sd	s7,24(sp)
    553e:	1080                	addi	s0,sp,96
    5540:	8baa                	mv	s7,a0
    5542:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    5544:	892a                	mv	s2,a0
    5546:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    5548:	4aa9                	li	s5,10
    554a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    554c:	89a6                	mv	s3,s1
    554e:	2485                	addiw	s1,s1,1
    5550:	0344d863          	bge	s1,s4,5580 <gets+0x56>
    cc = read(0, &c, 1);
    5554:	4605                	li	a2,1
    5556:	faf40593          	addi	a1,s0,-81
    555a:	4501                	li	a0,0
    555c:	00000097          	auipc	ra,0x0
    5560:	19c080e7          	jalr	412(ra) # 56f8 <read>
    if(cc < 1)
    5564:	00a05e63          	blez	a0,5580 <gets+0x56>
    buf[i++] = c;
    5568:	faf44783          	lbu	a5,-81(s0)
    556c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    5570:	01578763          	beq	a5,s5,557e <gets+0x54>
    5574:	0905                	addi	s2,s2,1
    5576:	fd679be3          	bne	a5,s6,554c <gets+0x22>
  for(i=0; i+1 < max; ){
    557a:	89a6                	mv	s3,s1
    557c:	a011                	j	5580 <gets+0x56>
    557e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    5580:	99de                	add	s3,s3,s7
    5582:	00098023          	sb	zero,0(s3)
  return buf;
}
    5586:	855e                	mv	a0,s7
    5588:	60e6                	ld	ra,88(sp)
    558a:	6446                	ld	s0,80(sp)
    558c:	64a6                	ld	s1,72(sp)
    558e:	6906                	ld	s2,64(sp)
    5590:	79e2                	ld	s3,56(sp)
    5592:	7a42                	ld	s4,48(sp)
    5594:	7aa2                	ld	s5,40(sp)
    5596:	7b02                	ld	s6,32(sp)
    5598:	6be2                	ld	s7,24(sp)
    559a:	6125                	addi	sp,sp,96
    559c:	8082                	ret

000000000000559e <stat>:

int
stat(const char *n, struct stat *st)
{
    559e:	1101                	addi	sp,sp,-32
    55a0:	ec06                	sd	ra,24(sp)
    55a2:	e822                	sd	s0,16(sp)
    55a4:	e426                	sd	s1,8(sp)
    55a6:	e04a                	sd	s2,0(sp)
    55a8:	1000                	addi	s0,sp,32
    55aa:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    55ac:	4581                	li	a1,0
    55ae:	00000097          	auipc	ra,0x0
    55b2:	172080e7          	jalr	370(ra) # 5720 <open>
  if(fd < 0)
    55b6:	02054563          	bltz	a0,55e0 <stat+0x42>
    55ba:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    55bc:	85ca                	mv	a1,s2
    55be:	00000097          	auipc	ra,0x0
    55c2:	17a080e7          	jalr	378(ra) # 5738 <fstat>
    55c6:	892a                	mv	s2,a0
  close(fd);
    55c8:	8526                	mv	a0,s1
    55ca:	00000097          	auipc	ra,0x0
    55ce:	13e080e7          	jalr	318(ra) # 5708 <close>
  return r;
}
    55d2:	854a                	mv	a0,s2
    55d4:	60e2                	ld	ra,24(sp)
    55d6:	6442                	ld	s0,16(sp)
    55d8:	64a2                	ld	s1,8(sp)
    55da:	6902                	ld	s2,0(sp)
    55dc:	6105                	addi	sp,sp,32
    55de:	8082                	ret
    return -1;
    55e0:	597d                	li	s2,-1
    55e2:	bfc5                	j	55d2 <stat+0x34>

00000000000055e4 <atoi>:

int
atoi(const char *s)
{
    55e4:	1141                	addi	sp,sp,-16
    55e6:	e422                	sd	s0,8(sp)
    55e8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    55ea:	00054603          	lbu	a2,0(a0)
    55ee:	fd06079b          	addiw	a5,a2,-48
    55f2:	0ff7f793          	andi	a5,a5,255
    55f6:	4725                	li	a4,9
    55f8:	02f76963          	bltu	a4,a5,562a <atoi+0x46>
    55fc:	86aa                	mv	a3,a0
  n = 0;
    55fe:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    5600:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    5602:	0685                	addi	a3,a3,1
    5604:	0025179b          	slliw	a5,a0,0x2
    5608:	9fa9                	addw	a5,a5,a0
    560a:	0017979b          	slliw	a5,a5,0x1
    560e:	9fb1                	addw	a5,a5,a2
    5610:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    5614:	0006c603          	lbu	a2,0(a3)
    5618:	fd06071b          	addiw	a4,a2,-48
    561c:	0ff77713          	andi	a4,a4,255
    5620:	fee5f1e3          	bgeu	a1,a4,5602 <atoi+0x1e>
  return n;
}
    5624:	6422                	ld	s0,8(sp)
    5626:	0141                	addi	sp,sp,16
    5628:	8082                	ret
  n = 0;
    562a:	4501                	li	a0,0
    562c:	bfe5                	j	5624 <atoi+0x40>

000000000000562e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    562e:	1141                	addi	sp,sp,-16
    5630:	e422                	sd	s0,8(sp)
    5632:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    5634:	02b57463          	bgeu	a0,a1,565c <memmove+0x2e>
    while(n-- > 0)
    5638:	00c05f63          	blez	a2,5656 <memmove+0x28>
    563c:	1602                	slli	a2,a2,0x20
    563e:	9201                	srli	a2,a2,0x20
    5640:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    5644:	872a                	mv	a4,a0
      *dst++ = *src++;
    5646:	0585                	addi	a1,a1,1
    5648:	0705                	addi	a4,a4,1
    564a:	fff5c683          	lbu	a3,-1(a1)
    564e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    5652:	fee79ae3          	bne	a5,a4,5646 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    5656:	6422                	ld	s0,8(sp)
    5658:	0141                	addi	sp,sp,16
    565a:	8082                	ret
    dst += n;
    565c:	00c50733          	add	a4,a0,a2
    src += n;
    5660:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    5662:	fec05ae3          	blez	a2,5656 <memmove+0x28>
    5666:	fff6079b          	addiw	a5,a2,-1
    566a:	1782                	slli	a5,a5,0x20
    566c:	9381                	srli	a5,a5,0x20
    566e:	fff7c793          	not	a5,a5
    5672:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    5674:	15fd                	addi	a1,a1,-1
    5676:	177d                	addi	a4,a4,-1
    5678:	0005c683          	lbu	a3,0(a1)
    567c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    5680:	fee79ae3          	bne	a5,a4,5674 <memmove+0x46>
    5684:	bfc9                	j	5656 <memmove+0x28>

0000000000005686 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    5686:	1141                	addi	sp,sp,-16
    5688:	e422                	sd	s0,8(sp)
    568a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    568c:	ca05                	beqz	a2,56bc <memcmp+0x36>
    568e:	fff6069b          	addiw	a3,a2,-1
    5692:	1682                	slli	a3,a3,0x20
    5694:	9281                	srli	a3,a3,0x20
    5696:	0685                	addi	a3,a3,1
    5698:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    569a:	00054783          	lbu	a5,0(a0)
    569e:	0005c703          	lbu	a4,0(a1)
    56a2:	00e79863          	bne	a5,a4,56b2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    56a6:	0505                	addi	a0,a0,1
    p2++;
    56a8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    56aa:	fed518e3          	bne	a0,a3,569a <memcmp+0x14>
  }
  return 0;
    56ae:	4501                	li	a0,0
    56b0:	a019                	j	56b6 <memcmp+0x30>
      return *p1 - *p2;
    56b2:	40e7853b          	subw	a0,a5,a4
}
    56b6:	6422                	ld	s0,8(sp)
    56b8:	0141                	addi	sp,sp,16
    56ba:	8082                	ret
  return 0;
    56bc:	4501                	li	a0,0
    56be:	bfe5                	j	56b6 <memcmp+0x30>

00000000000056c0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    56c0:	1141                	addi	sp,sp,-16
    56c2:	e406                	sd	ra,8(sp)
    56c4:	e022                	sd	s0,0(sp)
    56c6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    56c8:	00000097          	auipc	ra,0x0
    56cc:	f66080e7          	jalr	-154(ra) # 562e <memmove>
}
    56d0:	60a2                	ld	ra,8(sp)
    56d2:	6402                	ld	s0,0(sp)
    56d4:	0141                	addi	sp,sp,16
    56d6:	8082                	ret

00000000000056d8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    56d8:	4885                	li	a7,1
 ecall
    56da:	00000073          	ecall
 ret
    56de:	8082                	ret

00000000000056e0 <exit>:
.global exit
exit:
 li a7, SYS_exit
    56e0:	4889                	li	a7,2
 ecall
    56e2:	00000073          	ecall
 ret
    56e6:	8082                	ret

00000000000056e8 <wait>:
.global wait
wait:
 li a7, SYS_wait
    56e8:	488d                	li	a7,3
 ecall
    56ea:	00000073          	ecall
 ret
    56ee:	8082                	ret

00000000000056f0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    56f0:	4891                	li	a7,4
 ecall
    56f2:	00000073          	ecall
 ret
    56f6:	8082                	ret

00000000000056f8 <read>:
.global read
read:
 li a7, SYS_read
    56f8:	4895                	li	a7,5
 ecall
    56fa:	00000073          	ecall
 ret
    56fe:	8082                	ret

0000000000005700 <write>:
.global write
write:
 li a7, SYS_write
    5700:	48c1                	li	a7,16
 ecall
    5702:	00000073          	ecall
 ret
    5706:	8082                	ret

0000000000005708 <close>:
.global close
close:
 li a7, SYS_close
    5708:	48d5                	li	a7,21
 ecall
    570a:	00000073          	ecall
 ret
    570e:	8082                	ret

0000000000005710 <kill>:
.global kill
kill:
 li a7, SYS_kill
    5710:	4899                	li	a7,6
 ecall
    5712:	00000073          	ecall
 ret
    5716:	8082                	ret

0000000000005718 <exec>:
.global exec
exec:
 li a7, SYS_exec
    5718:	489d                	li	a7,7
 ecall
    571a:	00000073          	ecall
 ret
    571e:	8082                	ret

0000000000005720 <open>:
.global open
open:
 li a7, SYS_open
    5720:	48bd                	li	a7,15
 ecall
    5722:	00000073          	ecall
 ret
    5726:	8082                	ret

0000000000005728 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5728:	48c5                	li	a7,17
 ecall
    572a:	00000073          	ecall
 ret
    572e:	8082                	ret

0000000000005730 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    5730:	48c9                	li	a7,18
 ecall
    5732:	00000073          	ecall
 ret
    5736:	8082                	ret

0000000000005738 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5738:	48a1                	li	a7,8
 ecall
    573a:	00000073          	ecall
 ret
    573e:	8082                	ret

0000000000005740 <link>:
.global link
link:
 li a7, SYS_link
    5740:	48cd                	li	a7,19
 ecall
    5742:	00000073          	ecall
 ret
    5746:	8082                	ret

0000000000005748 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5748:	48d1                	li	a7,20
 ecall
    574a:	00000073          	ecall
 ret
    574e:	8082                	ret

0000000000005750 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    5750:	48a5                	li	a7,9
 ecall
    5752:	00000073          	ecall
 ret
    5756:	8082                	ret

0000000000005758 <dup>:
.global dup
dup:
 li a7, SYS_dup
    5758:	48a9                	li	a7,10
 ecall
    575a:	00000073          	ecall
 ret
    575e:	8082                	ret

0000000000005760 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    5760:	48ad                	li	a7,11
 ecall
    5762:	00000073          	ecall
 ret
    5766:	8082                	ret

0000000000005768 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    5768:	48b1                	li	a7,12
 ecall
    576a:	00000073          	ecall
 ret
    576e:	8082                	ret

0000000000005770 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    5770:	48b5                	li	a7,13
 ecall
    5772:	00000073          	ecall
 ret
    5776:	8082                	ret

0000000000005778 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5778:	48b9                	li	a7,14
 ecall
    577a:	00000073          	ecall
 ret
    577e:	8082                	ret

0000000000005780 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5780:	1101                	addi	sp,sp,-32
    5782:	ec06                	sd	ra,24(sp)
    5784:	e822                	sd	s0,16(sp)
    5786:	1000                	addi	s0,sp,32
    5788:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    578c:	4605                	li	a2,1
    578e:	fef40593          	addi	a1,s0,-17
    5792:	00000097          	auipc	ra,0x0
    5796:	f6e080e7          	jalr	-146(ra) # 5700 <write>
}
    579a:	60e2                	ld	ra,24(sp)
    579c:	6442                	ld	s0,16(sp)
    579e:	6105                	addi	sp,sp,32
    57a0:	8082                	ret

00000000000057a2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    57a2:	7139                	addi	sp,sp,-64
    57a4:	fc06                	sd	ra,56(sp)
    57a6:	f822                	sd	s0,48(sp)
    57a8:	f426                	sd	s1,40(sp)
    57aa:	f04a                	sd	s2,32(sp)
    57ac:	ec4e                	sd	s3,24(sp)
    57ae:	0080                	addi	s0,sp,64
    57b0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    57b2:	c299                	beqz	a3,57b8 <printint+0x16>
    57b4:	0805c863          	bltz	a1,5844 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    57b8:	2581                	sext.w	a1,a1
  neg = 0;
    57ba:	4881                	li	a7,0
    57bc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    57c0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    57c2:	2601                	sext.w	a2,a2
    57c4:	00003517          	auipc	a0,0x3
    57c8:	bc450513          	addi	a0,a0,-1084 # 8388 <digits>
    57cc:	883a                	mv	a6,a4
    57ce:	2705                	addiw	a4,a4,1
    57d0:	02c5f7bb          	remuw	a5,a1,a2
    57d4:	1782                	slli	a5,a5,0x20
    57d6:	9381                	srli	a5,a5,0x20
    57d8:	97aa                	add	a5,a5,a0
    57da:	0007c783          	lbu	a5,0(a5)
    57de:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    57e2:	0005879b          	sext.w	a5,a1
    57e6:	02c5d5bb          	divuw	a1,a1,a2
    57ea:	0685                	addi	a3,a3,1
    57ec:	fec7f0e3          	bgeu	a5,a2,57cc <printint+0x2a>
  if(neg)
    57f0:	00088b63          	beqz	a7,5806 <printint+0x64>
    buf[i++] = '-';
    57f4:	fd040793          	addi	a5,s0,-48
    57f8:	973e                	add	a4,a4,a5
    57fa:	02d00793          	li	a5,45
    57fe:	fef70823          	sb	a5,-16(a4)
    5802:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    5806:	02e05863          	blez	a4,5836 <printint+0x94>
    580a:	fc040793          	addi	a5,s0,-64
    580e:	00e78933          	add	s2,a5,a4
    5812:	fff78993          	addi	s3,a5,-1
    5816:	99ba                	add	s3,s3,a4
    5818:	377d                	addiw	a4,a4,-1
    581a:	1702                	slli	a4,a4,0x20
    581c:	9301                	srli	a4,a4,0x20
    581e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5822:	fff94583          	lbu	a1,-1(s2)
    5826:	8526                	mv	a0,s1
    5828:	00000097          	auipc	ra,0x0
    582c:	f58080e7          	jalr	-168(ra) # 5780 <putc>
  while(--i >= 0)
    5830:	197d                	addi	s2,s2,-1
    5832:	ff3918e3          	bne	s2,s3,5822 <printint+0x80>
}
    5836:	70e2                	ld	ra,56(sp)
    5838:	7442                	ld	s0,48(sp)
    583a:	74a2                	ld	s1,40(sp)
    583c:	7902                	ld	s2,32(sp)
    583e:	69e2                	ld	s3,24(sp)
    5840:	6121                	addi	sp,sp,64
    5842:	8082                	ret
    x = -xx;
    5844:	40b005bb          	negw	a1,a1
    neg = 1;
    5848:	4885                	li	a7,1
    x = -xx;
    584a:	bf8d                	j	57bc <printint+0x1a>

000000000000584c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    584c:	7119                	addi	sp,sp,-128
    584e:	fc86                	sd	ra,120(sp)
    5850:	f8a2                	sd	s0,112(sp)
    5852:	f4a6                	sd	s1,104(sp)
    5854:	f0ca                	sd	s2,96(sp)
    5856:	ecce                	sd	s3,88(sp)
    5858:	e8d2                	sd	s4,80(sp)
    585a:	e4d6                	sd	s5,72(sp)
    585c:	e0da                	sd	s6,64(sp)
    585e:	fc5e                	sd	s7,56(sp)
    5860:	f862                	sd	s8,48(sp)
    5862:	f466                	sd	s9,40(sp)
    5864:	f06a                	sd	s10,32(sp)
    5866:	ec6e                	sd	s11,24(sp)
    5868:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    586a:	0005c903          	lbu	s2,0(a1)
    586e:	18090f63          	beqz	s2,5a0c <vprintf+0x1c0>
    5872:	8aaa                	mv	s5,a0
    5874:	8b32                	mv	s6,a2
    5876:	00158493          	addi	s1,a1,1
  state = 0;
    587a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    587c:	02500a13          	li	s4,37
      if(c == 'd'){
    5880:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    5884:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    5888:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    588c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5890:	00003b97          	auipc	s7,0x3
    5894:	af8b8b93          	addi	s7,s7,-1288 # 8388 <digits>
    5898:	a839                	j	58b6 <vprintf+0x6a>
        putc(fd, c);
    589a:	85ca                	mv	a1,s2
    589c:	8556                	mv	a0,s5
    589e:	00000097          	auipc	ra,0x0
    58a2:	ee2080e7          	jalr	-286(ra) # 5780 <putc>
    58a6:	a019                	j	58ac <vprintf+0x60>
    } else if(state == '%'){
    58a8:	01498f63          	beq	s3,s4,58c6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    58ac:	0485                	addi	s1,s1,1
    58ae:	fff4c903          	lbu	s2,-1(s1)
    58b2:	14090d63          	beqz	s2,5a0c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    58b6:	0009079b          	sext.w	a5,s2
    if(state == 0){
    58ba:	fe0997e3          	bnez	s3,58a8 <vprintf+0x5c>
      if(c == '%'){
    58be:	fd479ee3          	bne	a5,s4,589a <vprintf+0x4e>
        state = '%';
    58c2:	89be                	mv	s3,a5
    58c4:	b7e5                	j	58ac <vprintf+0x60>
      if(c == 'd'){
    58c6:	05878063          	beq	a5,s8,5906 <vprintf+0xba>
      } else if(c == 'l') {
    58ca:	05978c63          	beq	a5,s9,5922 <vprintf+0xd6>
      } else if(c == 'x') {
    58ce:	07a78863          	beq	a5,s10,593e <vprintf+0xf2>
      } else if(c == 'p') {
    58d2:	09b78463          	beq	a5,s11,595a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    58d6:	07300713          	li	a4,115
    58da:	0ce78663          	beq	a5,a4,59a6 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    58de:	06300713          	li	a4,99
    58e2:	0ee78e63          	beq	a5,a4,59de <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    58e6:	11478863          	beq	a5,s4,59f6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    58ea:	85d2                	mv	a1,s4
    58ec:	8556                	mv	a0,s5
    58ee:	00000097          	auipc	ra,0x0
    58f2:	e92080e7          	jalr	-366(ra) # 5780 <putc>
        putc(fd, c);
    58f6:	85ca                	mv	a1,s2
    58f8:	8556                	mv	a0,s5
    58fa:	00000097          	auipc	ra,0x0
    58fe:	e86080e7          	jalr	-378(ra) # 5780 <putc>
      }
      state = 0;
    5902:	4981                	li	s3,0
    5904:	b765                	j	58ac <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    5906:	008b0913          	addi	s2,s6,8
    590a:	4685                	li	a3,1
    590c:	4629                	li	a2,10
    590e:	000b2583          	lw	a1,0(s6)
    5912:	8556                	mv	a0,s5
    5914:	00000097          	auipc	ra,0x0
    5918:	e8e080e7          	jalr	-370(ra) # 57a2 <printint>
    591c:	8b4a                	mv	s6,s2
      state = 0;
    591e:	4981                	li	s3,0
    5920:	b771                	j	58ac <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5922:	008b0913          	addi	s2,s6,8
    5926:	4681                	li	a3,0
    5928:	4629                	li	a2,10
    592a:	000b2583          	lw	a1,0(s6)
    592e:	8556                	mv	a0,s5
    5930:	00000097          	auipc	ra,0x0
    5934:	e72080e7          	jalr	-398(ra) # 57a2 <printint>
    5938:	8b4a                	mv	s6,s2
      state = 0;
    593a:	4981                	li	s3,0
    593c:	bf85                	j	58ac <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    593e:	008b0913          	addi	s2,s6,8
    5942:	4681                	li	a3,0
    5944:	4641                	li	a2,16
    5946:	000b2583          	lw	a1,0(s6)
    594a:	8556                	mv	a0,s5
    594c:	00000097          	auipc	ra,0x0
    5950:	e56080e7          	jalr	-426(ra) # 57a2 <printint>
    5954:	8b4a                	mv	s6,s2
      state = 0;
    5956:	4981                	li	s3,0
    5958:	bf91                	j	58ac <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    595a:	008b0793          	addi	a5,s6,8
    595e:	f8f43423          	sd	a5,-120(s0)
    5962:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    5966:	03000593          	li	a1,48
    596a:	8556                	mv	a0,s5
    596c:	00000097          	auipc	ra,0x0
    5970:	e14080e7          	jalr	-492(ra) # 5780 <putc>
  putc(fd, 'x');
    5974:	85ea                	mv	a1,s10
    5976:	8556                	mv	a0,s5
    5978:	00000097          	auipc	ra,0x0
    597c:	e08080e7          	jalr	-504(ra) # 5780 <putc>
    5980:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5982:	03c9d793          	srli	a5,s3,0x3c
    5986:	97de                	add	a5,a5,s7
    5988:	0007c583          	lbu	a1,0(a5)
    598c:	8556                	mv	a0,s5
    598e:	00000097          	auipc	ra,0x0
    5992:	df2080e7          	jalr	-526(ra) # 5780 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5996:	0992                	slli	s3,s3,0x4
    5998:	397d                	addiw	s2,s2,-1
    599a:	fe0914e3          	bnez	s2,5982 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    599e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    59a2:	4981                	li	s3,0
    59a4:	b721                	j	58ac <vprintf+0x60>
        s = va_arg(ap, char*);
    59a6:	008b0993          	addi	s3,s6,8
    59aa:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    59ae:	02090163          	beqz	s2,59d0 <vprintf+0x184>
        while(*s != 0){
    59b2:	00094583          	lbu	a1,0(s2)
    59b6:	c9a1                	beqz	a1,5a06 <vprintf+0x1ba>
          putc(fd, *s);
    59b8:	8556                	mv	a0,s5
    59ba:	00000097          	auipc	ra,0x0
    59be:	dc6080e7          	jalr	-570(ra) # 5780 <putc>
          s++;
    59c2:	0905                	addi	s2,s2,1
        while(*s != 0){
    59c4:	00094583          	lbu	a1,0(s2)
    59c8:	f9e5                	bnez	a1,59b8 <vprintf+0x16c>
        s = va_arg(ap, char*);
    59ca:	8b4e                	mv	s6,s3
      state = 0;
    59cc:	4981                	li	s3,0
    59ce:	bdf9                	j	58ac <vprintf+0x60>
          s = "(null)";
    59d0:	00003917          	auipc	s2,0x3
    59d4:	9b090913          	addi	s2,s2,-1616 # 8380 <malloc+0x286a>
        while(*s != 0){
    59d8:	02800593          	li	a1,40
    59dc:	bff1                	j	59b8 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    59de:	008b0913          	addi	s2,s6,8
    59e2:	000b4583          	lbu	a1,0(s6)
    59e6:	8556                	mv	a0,s5
    59e8:	00000097          	auipc	ra,0x0
    59ec:	d98080e7          	jalr	-616(ra) # 5780 <putc>
    59f0:	8b4a                	mv	s6,s2
      state = 0;
    59f2:	4981                	li	s3,0
    59f4:	bd65                	j	58ac <vprintf+0x60>
        putc(fd, c);
    59f6:	85d2                	mv	a1,s4
    59f8:	8556                	mv	a0,s5
    59fa:	00000097          	auipc	ra,0x0
    59fe:	d86080e7          	jalr	-634(ra) # 5780 <putc>
      state = 0;
    5a02:	4981                	li	s3,0
    5a04:	b565                	j	58ac <vprintf+0x60>
        s = va_arg(ap, char*);
    5a06:	8b4e                	mv	s6,s3
      state = 0;
    5a08:	4981                	li	s3,0
    5a0a:	b54d                	j	58ac <vprintf+0x60>
    }
  }
}
    5a0c:	70e6                	ld	ra,120(sp)
    5a0e:	7446                	ld	s0,112(sp)
    5a10:	74a6                	ld	s1,104(sp)
    5a12:	7906                	ld	s2,96(sp)
    5a14:	69e6                	ld	s3,88(sp)
    5a16:	6a46                	ld	s4,80(sp)
    5a18:	6aa6                	ld	s5,72(sp)
    5a1a:	6b06                	ld	s6,64(sp)
    5a1c:	7be2                	ld	s7,56(sp)
    5a1e:	7c42                	ld	s8,48(sp)
    5a20:	7ca2                	ld	s9,40(sp)
    5a22:	7d02                	ld	s10,32(sp)
    5a24:	6de2                	ld	s11,24(sp)
    5a26:	6109                	addi	sp,sp,128
    5a28:	8082                	ret

0000000000005a2a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5a2a:	715d                	addi	sp,sp,-80
    5a2c:	ec06                	sd	ra,24(sp)
    5a2e:	e822                	sd	s0,16(sp)
    5a30:	1000                	addi	s0,sp,32
    5a32:	e010                	sd	a2,0(s0)
    5a34:	e414                	sd	a3,8(s0)
    5a36:	e818                	sd	a4,16(s0)
    5a38:	ec1c                	sd	a5,24(s0)
    5a3a:	03043023          	sd	a6,32(s0)
    5a3e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5a42:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5a46:	8622                	mv	a2,s0
    5a48:	00000097          	auipc	ra,0x0
    5a4c:	e04080e7          	jalr	-508(ra) # 584c <vprintf>
}
    5a50:	60e2                	ld	ra,24(sp)
    5a52:	6442                	ld	s0,16(sp)
    5a54:	6161                	addi	sp,sp,80
    5a56:	8082                	ret

0000000000005a58 <printf>:

void
printf(const char *fmt, ...)
{
    5a58:	711d                	addi	sp,sp,-96
    5a5a:	ec06                	sd	ra,24(sp)
    5a5c:	e822                	sd	s0,16(sp)
    5a5e:	1000                	addi	s0,sp,32
    5a60:	e40c                	sd	a1,8(s0)
    5a62:	e810                	sd	a2,16(s0)
    5a64:	ec14                	sd	a3,24(s0)
    5a66:	f018                	sd	a4,32(s0)
    5a68:	f41c                	sd	a5,40(s0)
    5a6a:	03043823          	sd	a6,48(s0)
    5a6e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5a72:	00840613          	addi	a2,s0,8
    5a76:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5a7a:	85aa                	mv	a1,a0
    5a7c:	4505                	li	a0,1
    5a7e:	00000097          	auipc	ra,0x0
    5a82:	dce080e7          	jalr	-562(ra) # 584c <vprintf>
}
    5a86:	60e2                	ld	ra,24(sp)
    5a88:	6442                	ld	s0,16(sp)
    5a8a:	6125                	addi	sp,sp,96
    5a8c:	8082                	ret

0000000000005a8e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5a8e:	1141                	addi	sp,sp,-16
    5a90:	e422                	sd	s0,8(sp)
    5a92:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5a94:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5a98:	00003797          	auipc	a5,0x3
    5a9c:	9187b783          	ld	a5,-1768(a5) # 83b0 <freep>
    5aa0:	a805                	j	5ad0 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5aa2:	4618                	lw	a4,8(a2)
    5aa4:	9db9                	addw	a1,a1,a4
    5aa6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5aaa:	6398                	ld	a4,0(a5)
    5aac:	6318                	ld	a4,0(a4)
    5aae:	fee53823          	sd	a4,-16(a0)
    5ab2:	a091                	j	5af6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    5ab4:	ff852703          	lw	a4,-8(a0)
    5ab8:	9e39                	addw	a2,a2,a4
    5aba:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    5abc:	ff053703          	ld	a4,-16(a0)
    5ac0:	e398                	sd	a4,0(a5)
    5ac2:	a099                	j	5b08 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5ac4:	6398                	ld	a4,0(a5)
    5ac6:	00e7e463          	bltu	a5,a4,5ace <free+0x40>
    5aca:	00e6ea63          	bltu	a3,a4,5ade <free+0x50>
{
    5ace:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5ad0:	fed7fae3          	bgeu	a5,a3,5ac4 <free+0x36>
    5ad4:	6398                	ld	a4,0(a5)
    5ad6:	00e6e463          	bltu	a3,a4,5ade <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5ada:	fee7eae3          	bltu	a5,a4,5ace <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    5ade:	ff852583          	lw	a1,-8(a0)
    5ae2:	6390                	ld	a2,0(a5)
    5ae4:	02059813          	slli	a6,a1,0x20
    5ae8:	01c85713          	srli	a4,a6,0x1c
    5aec:	9736                	add	a4,a4,a3
    5aee:	fae60ae3          	beq	a2,a4,5aa2 <free+0x14>
    bp->s.ptr = p->s.ptr;
    5af2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5af6:	4790                	lw	a2,8(a5)
    5af8:	02061593          	slli	a1,a2,0x20
    5afc:	01c5d713          	srli	a4,a1,0x1c
    5b00:	973e                	add	a4,a4,a5
    5b02:	fae689e3          	beq	a3,a4,5ab4 <free+0x26>
  } else
    p->s.ptr = bp;
    5b06:	e394                	sd	a3,0(a5)
  freep = p;
    5b08:	00003717          	auipc	a4,0x3
    5b0c:	8af73423          	sd	a5,-1880(a4) # 83b0 <freep>
}
    5b10:	6422                	ld	s0,8(sp)
    5b12:	0141                	addi	sp,sp,16
    5b14:	8082                	ret

0000000000005b16 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5b16:	7139                	addi	sp,sp,-64
    5b18:	fc06                	sd	ra,56(sp)
    5b1a:	f822                	sd	s0,48(sp)
    5b1c:	f426                	sd	s1,40(sp)
    5b1e:	f04a                	sd	s2,32(sp)
    5b20:	ec4e                	sd	s3,24(sp)
    5b22:	e852                	sd	s4,16(sp)
    5b24:	e456                	sd	s5,8(sp)
    5b26:	e05a                	sd	s6,0(sp)
    5b28:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5b2a:	02051493          	slli	s1,a0,0x20
    5b2e:	9081                	srli	s1,s1,0x20
    5b30:	04bd                	addi	s1,s1,15
    5b32:	8091                	srli	s1,s1,0x4
    5b34:	0014899b          	addiw	s3,s1,1
    5b38:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    5b3a:	00003517          	auipc	a0,0x3
    5b3e:	87653503          	ld	a0,-1930(a0) # 83b0 <freep>
    5b42:	c515                	beqz	a0,5b6e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5b44:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5b46:	4798                	lw	a4,8(a5)
    5b48:	02977f63          	bgeu	a4,s1,5b86 <malloc+0x70>
    5b4c:	8a4e                	mv	s4,s3
    5b4e:	0009871b          	sext.w	a4,s3
    5b52:	6685                	lui	a3,0x1
    5b54:	00d77363          	bgeu	a4,a3,5b5a <malloc+0x44>
    5b58:	6a05                	lui	s4,0x1
    5b5a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5b5e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    5b62:	00003917          	auipc	s2,0x3
    5b66:	84e90913          	addi	s2,s2,-1970 # 83b0 <freep>
  if(p == (char*)-1)
    5b6a:	5afd                	li	s5,-1
    5b6c:	a895                	j	5be0 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    5b6e:	00009797          	auipc	a5,0x9
    5b72:	06278793          	addi	a5,a5,98 # ebd0 <base>
    5b76:	00003717          	auipc	a4,0x3
    5b7a:	82f73d23          	sd	a5,-1990(a4) # 83b0 <freep>
    5b7e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5b80:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5b84:	b7e1                	j	5b4c <malloc+0x36>
      if(p->s.size == nunits)
    5b86:	02e48c63          	beq	s1,a4,5bbe <malloc+0xa8>
        p->s.size -= nunits;
    5b8a:	4137073b          	subw	a4,a4,s3
    5b8e:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5b90:	02071693          	slli	a3,a4,0x20
    5b94:	01c6d713          	srli	a4,a3,0x1c
    5b98:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5b9a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5b9e:	00003717          	auipc	a4,0x3
    5ba2:	80a73923          	sd	a0,-2030(a4) # 83b0 <freep>
      return (void*)(p + 1);
    5ba6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    5baa:	70e2                	ld	ra,56(sp)
    5bac:	7442                	ld	s0,48(sp)
    5bae:	74a2                	ld	s1,40(sp)
    5bb0:	7902                	ld	s2,32(sp)
    5bb2:	69e2                	ld	s3,24(sp)
    5bb4:	6a42                	ld	s4,16(sp)
    5bb6:	6aa2                	ld	s5,8(sp)
    5bb8:	6b02                	ld	s6,0(sp)
    5bba:	6121                	addi	sp,sp,64
    5bbc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    5bbe:	6398                	ld	a4,0(a5)
    5bc0:	e118                	sd	a4,0(a0)
    5bc2:	bff1                	j	5b9e <malloc+0x88>
  hp->s.size = nu;
    5bc4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    5bc8:	0541                	addi	a0,a0,16
    5bca:	00000097          	auipc	ra,0x0
    5bce:	ec4080e7          	jalr	-316(ra) # 5a8e <free>
  return freep;
    5bd2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    5bd6:	d971                	beqz	a0,5baa <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5bd8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5bda:	4798                	lw	a4,8(a5)
    5bdc:	fa9775e3          	bgeu	a4,s1,5b86 <malloc+0x70>
    if(p == freep)
    5be0:	00093703          	ld	a4,0(s2)
    5be4:	853e                	mv	a0,a5
    5be6:	fef719e3          	bne	a4,a5,5bd8 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    5bea:	8552                	mv	a0,s4
    5bec:	00000097          	auipc	ra,0x0
    5bf0:	b7c080e7          	jalr	-1156(ra) # 5768 <sbrk>
  if(p == (char*)-1)
    5bf4:	fd5518e3          	bne	a0,s5,5bc4 <malloc+0xae>
        return 0;
    5bf8:	4501                	li	a0,0
    5bfa:	bf45                	j	5baa <malloc+0x94>
