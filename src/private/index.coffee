window.game = do ->
  ret = {}

  canvas = null
  data = [3,true,4,5,1]

  numbervisible = [
    [1,0,1,1,1,1,1],
    [0,0,0,0,1,0,1],
    [1,1,1,0,1,1,0],
    [1,1,1,0,1,0,1],
    [0,1,0,1,1,0,1],
    [1,1,1,1,0,0,1],
    [1,1,1,1,0,1,1],
    [1,0,0,0,1,0,1],
    [1,1,1,1,1,1,1],
    [1,1,1,1,1,0,1]
  ]

  matchesPos = []
  matchesObj = []

  pairAnimate = []

  timer =
    time : 0
    type : -1
    data : {}

  drawDigit = (x,y,n = 0) ->
    padding = 8
    pos = [[padding,0,0],[padding,100+padding*2,0],[padding,200+padding*4,0],[-50,50+padding,90],[50+padding*2,50+padding,90],[-50,150+padding*3,90],[50+padding*2,150+padding*3,90]]

    for p,i in pos
      matchesPos.push [x+p[0]+50,y+p[1]+12.5,p[2]]
      raster = new paper.Raster('src/images/matches.png')
      raster.scaling = 0.5
      raster.rotation = p[2]
      raster.position = new paper.Point( x+p[0]+50,y+p[1]+12.5 )
      if numbervisible[n][i] == 0
        raster.visible = false
      matchesObj.push raster

    return

  drawOperator = (x,y) ->
    matchesPos.push [ x,y,0 ]
    matchesPos.push [ x,y,90 ]

    raster = new paper.Raster('src/images/matches.png')
    raster.scaling = 0.5
    raster.position = new paper.Point( x,y )
    matchesObj.push raster

    raster = new paper.Raster('src/images/matches.png')
    raster.scaling = 0.5
    raster.rotation = 90
    raster.position = new paper.Point( x,y )
    if !data[1]
      raster.visible = false
    matchesObj.push raster

    return

  drawEqual = (x,y) ->
    raster = new paper.Raster('src/images/matches.png')
    raster.scaling = 0.5
    raster.position = new paper.Point( x,y-12 )

    raster = new paper.Raster('src/images/matches.png')
    raster.scaling = 0.5
    raster.position = new paper.Point( x,y+12 )
    return

  drawDigital = ->

    paper.project.activeLayer.removeChildren()
    matchesPos = []
    matchesObj = []

    $("#alerter").slideUp()

    drawDigit( 15,10,data[0] )
    drawOperator(220,150);
    drawDigit( 315,10,data[2] )
    drawEqual( 520,150 )
    drawDigit( 615,10,data[3] )

    paper.view.draw()

  ret.refresh = ->
    timer.type = -1
    drawDigital()

  ret.initial = ->
    canvas = $("#mainCanvas")[0]
    paper.setup( canvas )
    paper.view.viewSize = new paper.Size( 800,300 )

    width = $(".canvas-wrapper").innerWidth()
    width = Math.min( width,800 )
    $("#mainCanvas").css({width:width,height:width/800*300});

    drawDigital()

    paper.view.onFrame = (evt) ->
      if timer.type == -1
        return
      else if timer.type == 1
        timer.time += evt.delta
        ratio = 1 - timer.time
        for p in pairAnimate
          #console.log p,matchesObj[p[1]],matchesObj[p[0]]
          matchesObj[p[1]].position.x += ( matchesObj[p[0]].position.x - matchesObj[p[1]].position.x )/20
          matchesObj[p[1]].position.y += ( matchesObj[p[0]].position.y - matchesObj[p[1]].position.y )/20
          matchesObj[p[1]].rotation += ( matchesObj[p[0]].rotation - matchesObj[p[1]].rotation )/20
          if ( Math.abs(matchesObj[p[1]].rotation - matchesObj[p[0]].rotation ) < 0.1 and \
          Math.abs(matchesObj[p[1]].position.x - matchesObj[p[0]].position.x) < 0.1 and \
          Math.abs(matchesObj[p[1]].position.y - matchesObj[p[0]].position.y) < 0.1 )
            timer.type = -1

    return

  ret.setData = (n,v,up = false) ->
    data[n] = v
    timer.type = -1
    if up
      drawDigital()

  check = ( a,p,b ) ->
    diff = 0
    sym = 0
    c = if p == 1 then a+b else a-b
    aa = data[0]
    bb = data[2]
    cc = data[3]

    for q,i in numbervisible[a]
      if q != numbervisible[aa][i]
        diff++
        sym += q - numbervisible[aa][i]
    for q,i in numbervisible[b]
      if q != numbervisible[bb][i]
        diff++
        sym += q - numbervisible[bb][i]
    for q,i in numbervisible[c]
      if q != numbervisible[cc][i]
        diff++
        sym += q - numbervisible[cc][i]
    if ( data[1] == true and p != 1 ) or ( data[1] == false and p != 2 )
      diff++
      sym += ( if p == 1 then 1 else -1 )

    #console.log( a,p,b,c,data,diff,sym )
    if diff == data[4]*2 and sym == 0
      console.log( a,p,b,c,diff,sym )
      return true
    else
      return false

  pairing = ( a,p,b,c ) ->
    id = 0
    first = 0
    second = 0
    ret = ( [-1,-1] for i in [1..(data[4])] )
    aa = data[0]
    bb = data[2]
    cc = data[3]

    console.log ret

    for q,i in numbervisible[a]
      if q != numbervisible[aa][i]
        if q == 1
          ret[first++][0] = id
        else
          ret[second++][1] = id
      id++


    id += 2
    if ( data[1] == true and p != 1 ) or ( data[1] == false and p != 2 )
      if p == 1
        ret[first++][0] = id-1
      else
        ret[second++][1] = id-1

    for q,i in numbervisible[b]
      if q != numbervisible[bb][i]
        if q == 1
          ret[first++][0] = id
        else
          ret[second++][1] = id
      id++

    for q,i in numbervisible[c]
      if q != numbervisible[cc][i]
        if q == 1
          ret[first++][0] = id
        else
          ret[second++][1] = id
      id++

    pairAnimate = ret
    return

  animate = () ->
    $(document).scrollTop $("#mainCanvas").scrollTop()
    drawDigital()
    timer.time = 0
    timer.type = 1
    $("#alerter").html("<div onclick='game.refresh()' style='cursor:pointer;'>refresh</div>").slideDown()
    return

  ret.findSolution = () ->
    for first in [0..9]
      for operator in [1..2]
        for second in [0..9]
          if operator == 1
            if first + second >= 0 and first + second < 10
              if check( first,operator,second )
                pairing( first,operator,second,first+second )
                animate()
                return
          else
            if first - second >= 0 and first - second < 10
              if check( first,operator,second )
                pairing( first,operator,second,first-second )
                animate()
                return

    $("#alerter")
      .html("<div style='color:#d51515; font-size:1.3rem; margin:15px 0px; text-shadow: 1px 1px 0px rgba(0,0,0,0.1);'>No possible solution</div>").slideDown()
    return

  ret

$(->
  $(document).foundation()

  selectList = ['select1','select2','select3','select4','select5']

  selectList.forEach (elm)->
    $('#'+elm+" .selector").click do ()->
      ()->
        $("#"+elm).foundation('reveal','close')
        $(".selectable a[data-reveal-id='"+elm+"'] > div").text $(this).text()
        if $.inArray( elm,['select1','select3','select4'] ) != -1
          if elm == 'select1'
            nn = 0
          else if elm == 'select3'
            nn = 2
          else
            nn = 3
          game.setData nn,parseInt( $(this).text() ),true
        else if elm == 'select2'
          game.setData 1,($(this).text() == '+' ? 1 : 0),true
        else
          game.setData 4,parseInt( $(this).text() ),true
        return

  game.initial()
)
