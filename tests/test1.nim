import unittest
import std/math
import std/stats
import os

include nim_mcmc

proc testFun(x: float): float =
  if (x < 0):
    return 0
  else:
    return exp(-x)

proc normalPDF(x: float, mu: float, sigma: float): float =
  return (1 / (sigma * sqrt(2 * PI))) * exp(-0.5 * ((x - mu) / sigma) ^ 2)

proc testNormal(x: float): float =
  return normalPDF(x, 3.0, 0.7)

suite "MCMC Tests":
  setup:
    var sampleSize = 200000
    var burnin = sampleSize div 4
    var thinning = 4
    var sampleTestFun = mcmc(testFun, sampleSize, burnin, thinning)
    var sampleTestNormal = mcmc(testNormal, sampleSize, burnin, thinning)

  test "correct length":
    check(sampleTestFun.len == sampleSize)
    check(sampleTestNormal.len == sampleSize)

  test "correct statistics for Normal dist.":
    var statistics: RunningStat
    statistics.push(sampleTestNormal)
    echo "Mean difference: ", abs(statistics.mean() - 3.0),
        ", Variance difference: ", abs(statistics.variance() - 0.7),
        ", Skewness difference: ", abs(statistics.skewness() - 0.0),
        ", Kurtosis difference: ", abs(statistics.kurtosis() - 0.0)
    # Naive implementation - bad results
    check(abs(statistics.mean() - 3.0) < 0.01)
    # Need to decrease variance difference
    check(abs(statistics.variance() - 0.7) < 1)

  test "write to file & file exists":
    var fNameTestFun = writeToFile(sampleTestFun)
    check(fileExists(fNameTestFun))
