window.game = do ->
  ret = {}

  canvas = null
  data = [0,true,0,0]

  drawDigit = (x,y,n = 0) ->
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
    padding = 8
    pos = [[padding,0,0],[padding,100+padding*2,0],[padding,200+padding*4,0],[-50,50+padding,90],[50+padding*2,50+padding,90],[-50,150+padding*3,90],[50+padding*2,150+padding*3,90]]

    for p,i in pos
      if numbervisible[n][i] == 0
        continue
      raster = new paper.Raster('src/images/matches.png')
      raster.scaling = 0.5
      raster.rotation = p[2]
      raster.position = new paper.Point( x+p[0]+50,y+p[1]+12.5 )

    return

  drawOperator = (x,y) ->
    raster = new paper.Raster('src/images/matches.png')
    raster.scaling = 0.5
    raster.position = new paper.Point( x,y )

    if !data[1]
      return

    raster = new paper.Raster('src/images/matches.png')
    raster.scaling = 0.5
    raster.rotation = 90
    raster.position = new paper.Point( x,y )
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

  ret

$(->
  $(document).foundation()

  selectList = ['select1','select2','select3','select4']

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
        else
          game.setData 1,($(this).text() == '+' ? 1 : 0),true
        return

  game.initial()
)
