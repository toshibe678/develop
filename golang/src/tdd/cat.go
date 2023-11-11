package tdd
//https://qiita.com/tonnsama/items/af4ec31e35471220c8a2
type Cat struct {
}

func NewCat(sound string) *Cat {
	return &Cat{}
}

func (c *Cat) Cry() string {
	return "ニャーニャー"
}
