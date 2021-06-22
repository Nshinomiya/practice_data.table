library(tidyverse)
library(data.table)

# data.tableの作成====
DT <- data.table(
  ID = c("b", "b", "b", "a", "a", "c"),
  a = 1:6,
  b = 7:12, 
  c = 13:18
)
DT$ID %>% class()

# データの読み込み====
## 空のdata.tableを作成してfor文でrbind(遅い、リソース食うので非推奨)====
# rbindでclass attribute がマッチしないエラーにならない？
merged.dt <- data.table()
nums <- seq(1, 4) %>% as.character()
for(num in nums){
  add.dt <- fread(str_c("toy_cor", num, ".csv"))
  merged.dt <- merged.dt %>% rbind(add.dt)
}

## 複数のcsvを1つのdata.tableに読み込む（早い、スマート）====
# list.filesでカレントディレクトリのcsvファイルのフルパスを取得
files <- list.files(full.names = T, pattern = "csv")
# freadを使用して複数のcsvを1つのdata.tableにまとめる
# do.call：第二引数にリストを指定して、第一引数の処理（rbind）を一括で適用する
# lapply：第一引数のリストに関数を適用（fread）して結果をリストで返す(data.table=Fにするとdata.frameで返ってくる)
dt <- do.call(rbind, lapply(files, fread, sep=",", data.table=T))
cat("read count:", nrow(dt))
# dt %>% class()

# 集計、データ操作の練習====
# 練習用データの読み込み
input <- if(file.exists("flights14.csv")){
  "flights14.csv"
} else{
  "https://raw.githubusercontent.com/Rdatatable/data.table/master/vignettes/flights14.csv"
}
dt.flights <- fread(input)
dt.flights %>% dim()

# 条件で絞る====
# monthはintだが、なぜ6Lと指定するのか？？
ans <- dt.flights[origin=="JFK" & month==6L]
ans %>% head()
ans %>% str()

# 行の指定====
ans <- dt.flights[1:2]
ans

# 列の指定====
# listで指定するとクォーテーションはいらない
# listでくくらないとベクトルで返される
ans <- dt.flights[, list(arr_delay)]
ans %>% head()
# 「list」を省略して「.」でもOK
ans <- dt.flights[, .(arr_delay)]
ans %>% head()

# ベクトルで指定したいときはクォーテーションが必要
ans <- dt.flights[, c("year", "month")]
ans %>% head()

# 変数に格納したベクトルで指定したいときはwith=Fをつける
use_cols <- colnames(dt.flights)[1:4]
ans <- dt.flights[, use_cols, with=F]
ans %>% head()

# 特定の列を除いて指定するときは文字列で、前に-（マイナス）をつける
# ベクトルで
ans <- dt.flights[, -c("year", "month")]
ans %>% head()
# listで
ans <- dt.flights[, -list("year", "month")]
ans %>% head()

# 並べ替え====
# -(マイナス)で指定すると降順
ans <- dt.flights[order(origin, -dest)]
ans %>% head()
dt.flights %>% head()
