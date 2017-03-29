#!/bin/bash
# Usage parse_log.sh caffe.log
# It creates the following two text files, each containing a table:
#     caffe.log.test (columns: '#Iters Seconds TestAccuracy TestLoss')
#     caffe.log.train (columns: '#Iters Seconds TrainingLoss LearningRate')


# get the dirname of the script
DIR="$( cd "$(dirname "$0")" ; pwd -P )"

if [ "$#" -lt 1 ]
then
echo "Usage parse_log.sh /path/to/your.log"
exit
fi
# 获取基本文件名称，将路径和文件的后缀都去掉
LOG=`basename $1`
# sed命令行格式为：
#          sed [-nefri] ‘command’ 输入文本        
# 常用选项：
#         -n∶使用安静(silent)模式。在一般 sed 的用法中，所有来自 STDIN的资料一般都会被列出到萤幕上。但如果加上 -n 参数后，则只有经过sed 特殊处理的那一行(或者动作)才会被列出来。
#         -e∶直接在指令列模式上进行 sed 的动作编辑；
#         -f∶直接将 sed 的动作写在一个档案内， -f filename 则可以执行 filename 内的sed 动作；
#         -r∶sed 的动作支援的是延伸型正规表示法的语法。(预设是基础正规表示法语法)
#         -i∶直接修改读取的档案内容，而不是由萤幕输出。       
# 常用命令：
#         a   ∶新增， a 的后面可以接字串，而这些字串会在新的一行出现(目前的下一行)～
#         c   ∶取代， c 的后面可以接字串，这些字串可以取代 n1,n2 之间的行！
#         d   ∶删除，因为是删除啊，所以 d 后面通常不接任何咚咚；
#          i   ∶插入， i 的后面可以接字串，而这些字串会在新的一行出现(目前的上一行)；
#          p  ∶列印，亦即将某个选择的资料印出。通常 p 会与参数 sed -n 一起运作～
#          s  ∶取代，可以直接进行取代的工作哩！通常这个 s 的动作可以搭配正规表示法！例如 1,20s/old/new/g 就是啦！

sed -n '/Iteration .* Testing net/,/Iteration *. loss/p' $1 > aux.txt
sed -i '/Waiting for data/d' aux.txt
sed -i '/prefetch queue empty/d' aux.txt
sed -i '/Iteration .* loss/d' aux.txt
sed -i '/Iteration .* lr/d' aux.txt
sed -i '/Train net/d' aux.txt

# > 重定向符号 >>追加模式 http://www.cnblogs.com/vincently/p/4641098.html
grep 'Iteration ' aux.txt | sed  's/.*Iteration \([[:digit:]]*\).*/\1/g' > aux0.txt
grep 'Test net output #0' aux.txt | awk '{print $11}' > aux1.txt
grep 'Test net output #1' aux.txt | awk '{print $11}' > aux2.txt

# Extracting elapsed seconds
# For extraction of time since this line contains the start time
grep '] Solving ' $1 > aux3.txt
grep 'Testing net' $1 >> aux3.txt
$DIR/extract_seconds.py aux3.txt aux4.txt

# Generating
echo '#Iters Seconds TestAccuracy TestLoss'> $LOG.test
paste aux0.txt aux4.txt aux1.txt aux2.txt | column -t >> $LOG.test
rm aux.txt aux0.txt aux1.txt aux2.txt aux3.txt aux4.txt

# For extraction of time since this line contains the start time
grep '] Solving ' $1 > aux.txt
grep ', loss = ' $1 >> aux.txt
grep 'Iteration ' aux.txt | sed  's/.*Iteration \([[:digit:]]*\).*/\1/g' > aux0.txt
grep ', loss = ' $1 | awk '{print $9}' > aux1.txt
grep ', lr = ' $1 | awk '{print $9}' > aux2.txt

# Extracting elapsed seconds
$DIR/extract_seconds.py aux.txt aux3.txt

# Generating
echo '#Iters Seconds TrainingLoss LearningRate'> $LOG.train
paste aux0.txt aux3.txt aux1.txt aux2.txt | column -t >> $LOG.train
rm aux.txt aux0.txt aux1.txt aux2.txt  aux3.txt
