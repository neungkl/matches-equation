window.game = do ->
  ret = {}

  canvas = null
  data = [0,true,0,0,1]

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

    return

  drawOperator = (x,y) ->
    matchesPos.push [ x,y,0 ]
    matchesPos.push [ x,y,90 ]

    raster = new paper.Raster('src/images/matches.png')
    raster.scaling = 0.5
    raster.position = new paper.Point( x,y )

    raster = new paper.Raster('src/images/matches.png')
    raster.scaling = 0.5
    raster.rotation = 90
    raster.position = new paper.Point( x,y )
    if !data[1]
      raster.visible = false

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

    drawDigit( 15,10,data[0] )
    drawOperator(220,150);
    drawDigit( 315,10,data[2] )
    drawEqual( 520,150 )
    drawDigit( 615,10,data[3] )
    console.log matchesPos

    paper.view.draw()

  ret.initial = ->
    canvas = $("#mainCanvas")[0]
    paper.setup( canvas )
    paper.view.viewSize = new paper.Size( 800,300 )

    paper.view.onResize = (e) ->
      paper.view.viewSize = new Size( 800,300 )

    drawDigital()

    return

  ret.setData = (n,v,up = false) ->
    data[n] = v
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
        sym += q - numbervisible[aa][i]
    for q,i in numbervisible[c]
      if q != numbervisible[cc][i]
        diff++
        sym += q - numbervisible[aa][i]
    if ( data[1] == true and p != 1 ) or ( data[1] == false and p != 2 )
       diff++
       sym += if p == 1 then 1 else -1

    #console.log( a,p,b,c,data,diff,sym )
    if diff == data[4]*2 and sym == 0
      console.log( a,p,b,c )
      return false
    else
      return false

  ret.findSolution = () ->
    for first in [0..9]
      for operator in [1..2]
        for second in [0..9]
          if operator == 1
            if first + second >= 0 and first + second < 10
              if check( first,operator,second )
                return
          else
            if first - second >= 0 and first - second < 10
              if check( first,operator,second )
                return

  ret

$(->
  $(document).foundation()

  selectList = ['select1','select2','select3','select4','select5']

  selectList.forEach (elm)->
    $('#'+elm+" .selector").click do ()->
      ()->
        $("#"+elm).foundation('reveal','close')
        $(".selectable a[data-reveal-id='"+elm+"']").text $(this).text()
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
