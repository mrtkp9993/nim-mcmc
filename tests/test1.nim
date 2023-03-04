import unittest
import std/math

include nim_mcmc

proc testFun(x: float): float =
  if (x < 0):
    return 0
  else:
    return exp(-x)

suite "MCMC Tests":
  setup:
    var sampleSize = 10000
    var sampleTestFun = mcmc(testFun, sampleSize, 2000)

  test "correct length":
    check(sampleTestFun.len == sampleSize)
