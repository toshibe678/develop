package main_test

import (
	"github.com/stretchr/testify/assert"
	"tdd-sample"
	"testing"
)

func TestCry(t *testing.T) {
	c1 := tdd.NewCat("ニャーニャー")
	assert.Equal(t, "ニャーニャー", c1.Cry())
}
