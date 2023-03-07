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

proc logisticPDF(x: float, mu: float,  s:float): float = 
  assert s > 0
  return (exp((mu - x) / s) / (s * (1 + exp((mu - x) / s)) ^ 2))

proc testNormal(x: float): float =
  return normalPDF(x, 3.0, 0.7)

proc testLogistic(x: float): float = 
  return logisticPDF(x, 6.0, 2.0)

suite "MCMC Tests":
  setup:
    var sampleSize = 500000
    var burnin = sampleSize div 2
    var thinning = 4
    var sampleTestFun = mcmc(testFun, sampleSize, burnin, thinning)
    var sampleTestNormal = mcmc(testNormal, sampleSize, burnin, thinning)
    var sampleTestLogistic = mcmc(testLogistic, sampleSize, burnin, thinning)

  test "correct length":
    check(sampleTestFun.len == sampleSize)
    check(sampleTestNormal.len == sampleSize)
    check(sampleTestLogistic.len == sampleSize)

  test "correct statistics for Normal dist.":
    var statistics: RunningStat
    statistics.push(sampleTestNormal)
    echo "Mean difference: ", abs(statistics.mean() - 3.0),
        ", Variance difference: ", abs(statistics.variance() - 0.7),
        ", Skewness difference: ", abs(statistics.skewness() - 0.0),
        ", Kurtosis difference: ", abs(statistics.kurtosis() - 0.0)
    check(abs(statistics.mean() - 3.0) < 0.001)
    check(abs(statistics.variance() - 0.7) < 1)
    check(abs(statistics.skewness() - 0.0) < 0.1)
    check(abs(statistics.kurtosis() - 0.0) < 0.1)

  test "correct statistics for Logistic dist.":
    var theoreticalMean = 6.0
    var theoreticalVar = 4 * PI * PI / 3
    var theoreticalSkew = 0.0
    var theoreticalKurt = 6 / 5
    var statistics: RunningStat
    statistics.push(sampleTestLogistic)
    echo "Mean difference: ", abs(statistics.mean() - theoreticalMean),
      ", Variance difference: ", abs(statistics.variance() - theoreticalVar),
      ", Skewness difference: ", abs(statistics.skewness() - theoreticalSkew),
      ", Kurtosis difference: ", abs(statistics.kurtosis() - theoreticalKurt)
    check(abs(statistics.mean() - theoreticalMean) < 0.01)
    check(abs(statistics.variance() - theoreticalVar) < 0.1)
    check(abs(statistics.skewness() - theoreticalSkew) < 0.1)
    check(abs(statistics.kurtosis() - theoreticalKurt) < 0.1)

  test "write to file & file exists":
    var fNameTestFun = writeToFile(sampleTestFun)
    check(fileExists(fNameTestFun))
