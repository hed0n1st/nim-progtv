
when defined(cpu64):
  {.link: "resource/progtv64.res".}
else:
  {.link: "resource/progtv32.res".}

import
  os,
  docopt,
  uri,
  json,
  tables,
  times,
  strutils,
  httpclient

import core/[channels, termcolors]

const
  apiUrl = "http://api.programme-tv.net/v2/broadcasts"
  userAgent = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) " &
    "AppleWebKit/537.36 (KHTML, like Gecko) " &
    "Chrome/62.0.3202.75 Safari/537.36"
  )
  headers = {
    "User-Agent": userAgent,
    "Content-Language": "en-US; fr-FR",
    "Cache-Control": "max-age=0",
    "Accept": "*/*",
    "Accept-Language": "fr-FR,fr;q=0.8,en-US;q=0.8,en;q=0.7",
    "Content-type": "application/json",
    "Connection": "keep-alive"
  }

let doc = """
prog-TV : simple command line EPG

Usage:
  progtv list
  progtv now
  progtv prime [<date>]
  progtv <channel> [--now | --prime] [<date>]

"""

let args = docopt(doc, version = "0.1")
let proxy = newProxy("http://127.0.0.1:8888")
let client = newHttpClient(proxy = proxy)

proc getDate(): string =
  let dt = now()
  result = dt.format("yyyy-MM-dd")

proc doRequest[T](payload: openArray[T]): JsonNode =
  let apiUri = parseUri(apiUrl) ? payload
  let apiResp = client.request(
      url = $apiUri,
      httpMethod = HttpGet,
      headers = newHttpHeaders(headers)
    )
  let data = parseJson(apiResp.body)
  result = data["data"]["items"]

proc doTProgs(): Table[int, seq[string]] =
  for channel, id in idChannels.getFields():
    result[id.getStr.parseInt()] = @[]

proc buildProgs(progs: Table[int, seq[string]] or seq[string], data: JsonNode): Table[int, seq[string]] or seq[string] =
  when progs.type is Table[int, seq[string]]:
    result = progs
    for d in data:
      var idChannel = d["channel"]["id"].getInt()
      var progTitle = d["title"].getStr()
      var progStart = d["startedAt"].getStr()
      progStart = progStart.getProgStartTime()
      var prog = progStart & " ::: " & progTitle.fgBlue()
      result[idChannel].add(prog)

  when progs.type is seq[string]:
    result = progs
    for d in data:
      var progTitle = d["title"].getStr()
      var progStart = d["startedAt"].getStr()
      progStart = progStart.getProgStartTime()
      var prog = progStart & " ::: " & progTitle.fgBlue()
      result.insert(prog, 0)

proc displayProgs(t: Table[int, seq[string]]) =
  for channel, id in idChannels.getFields():
    var progs = t[id.getStr.parseInt()]
    for prog in progs:
      echo channel.fgYellow() & " ::: " & prog
  discard

proc doPayloadPrimetime(idChannel: string = "", date: string, primetimeSlot: int): array[0..4, (string, string)] =
  case idChannel
  of "":
    result = {
      "limit": "auto",
      "projection": "channel{id,title},title,startedAt,duration,program{id}",
      "date": date,
      "primetimeSlot": $primetimeSlot,
      "bouquets": "default",
    }
  else:
    result = {
      "limit": "auto",
      "projection": "channel{id,title},title,startedAt,duration,program{id}",
      "date": date,
      "primetimeSlot": $primetimeSlot,
      "channels": idChannel,
    }

proc doPayloadNow(): array[0..3, (string, string)] =
  result = {
    "limit": "auto",
    "projection": "channel{id,title},title,startedAt,duration,program{id}",
    "date": "now",
    "bouquets": "default",
  }

proc doPayload(idChannel: string, date: string): array[0..3, (string, string)] =
  result = {
    "limit": "auto",
    "projection": "channel{id,title},title,startedAt,duration,program{id}",
    "date": date,
    "channels": idChannel
  }

proc getProgStartTime(h: string): string =
  var h = h.split("T")[1]
            .split("+")[0]
  var hour = parseInt(h.split(":")[0]) + 1 # FR TIME
  var minutes = h.split(":")[1]
  result = $hour & ":" & minutes

when isMainModule:

  if args["list"]:
    for channel, id in idChannels.getFields():
      echo channel

  if args["now"]:
    let payload = doPayloadNow()
    let data = payload.doRequest()
    var progs = doTProgs()
    progs = progs.buildProgs(data)
    progs.displayProgs()

  if args["prime"]:
    var date: string
    if args["<date>"]:
      date = $args["<date>"]
    else:
      date = getDate()
    var data: JsonNode
    var payload: array[0..4, (string, string)]
    var progs = doTProgs()

    payload = doPayloadPrimetime(date = date, primetimeSlot = 1)
    data = payload.doRequest()
    progs = progs.buildProgs(data)

    sleep(500)

    payload = doPayloadPrimetime(date = date, primetimeSlot = 2)
    data = payload.dorequest()
    progs = progs.buildProgs(data)

    progs.displayProgs()

  if args["<channel>"]:
    var date: string
    if args["--now"]:
      date = "now"
    elif args["<date>"]:
      date = $args["<date>"]
    else:
      date = getDate()

    if not args["--prime"]:
      let idChannel = idChannels[$args["<channel>"]].getStr()
      let payload = doPayload(idChannel, date)
      var progs: seq[string]
      let data = payload.doRequest()
      progs = progs.buildProgs(data)

      for prog in progs:
        var c = $args["<channel>"]
        echo c.fgYellow() & " ::: " & prog

    if args["--prime"]:
      var data: JsonNode
      var payload: array[0..4, (string, string)]
      var progs: seq[string]
      let idChannel = idChannels[$args["<channel>"]].getStr()
      payload = doPayloadPrimetime(idChannel, date, 1)
      data = payload.dorequest()
      progs = progs.buildProgs(data)
      sleep(500)
      payload = doPayloadPrimetime(idChannel, date, 2)
      data = payload.dorequest()
      progs = progs.buildProgs(data)

      var c = $args["<channel>"]
      echo c.fgYellow() & " ::: " & progs[1]
      echo c.fgYellow() & " ::: " & progs[0]
