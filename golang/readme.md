## go 実行方法3個
### 実行（Modules を使用しない）
```sh
go run foo.go

go build foo.go
```

### 実行（Modules を使用する）
```sh
go mod init sample

go run .
go build
```

## ファイル２つで実行（同一パッケージ）
### 実行（Modules を使用しない）
```sh
go run foo.go bar.go
go build foo.go bar.go
```

### 実行（Modules を使用する）
```sh
go mod init sample

go run .
go build
```
