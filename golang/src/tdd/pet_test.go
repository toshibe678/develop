package tdd_test

import (
	"github.com/stretchr/testify/assert"
	main "tdd-sample"
	"testing"
)

func TestCry(t *testing.T) {
	c1 := main.NewCat("ニャーニャー")
	assert.Equal(t, "ニャーニャー", c1.Cry())
}
