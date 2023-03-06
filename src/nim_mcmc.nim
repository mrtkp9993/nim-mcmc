import std/random
import std/sugar
import std/sequtils
import std/strutils

const lowerCaseAscii = 97..122

# Direct translation of my C++ implementation
# as a first version
# https://github.com/mrtkp9993/Cpp-Examples/blob/master/lib/numericCppExamples/metropolisHastings.h
proc mcmc(fun: (float) -> float, ncount: int, burnInPeriod: int,
    thinning: int, chainCount: int): seq[float] =
  randomize()
  var tresult = newSeq[seq[float]](chainCount)
  for i in countUp(0, chainCount - 1):
    tresult[i] = newSeq[float](burnInPeriod + ncount * thinning)
    tresult[i][0] = 1.0

  for i in countUp(0, chainCount - 1):
    for j in countup(1, burnInPeriod + (ncount * thinning) - 1):
      var currentx: float = tresult[i][j - 1]
      var proposedx: float = currentx + gauss()
      var A: float = min(1, fun(proposedx) / fun(currentx))
      if (rand(1.0) < A):
        tresult[i][j] = proposedx
      else:
        tresult[i][j] = currentx

  result = collect(newseq):
    for i in countup(burnInPeriod, burnInPeriod + (ncount * thinning) - 1, thinning):
      var ssum:float = 0.0
      for j in countUp(0, chainCount - 1):
        ssum += tresult[j][i]
      ssum / float(chainCount)
  return result

proc writeToFile(res: seq[float]): string =
  var fname = $6.newSeqWith(lowerCaseAscii.rand.char).join & ".txt"
  let f = open(fname, fmWrite)
  defer: f.close()

  for r in res:
    f.writeLine(r)

  return fname
