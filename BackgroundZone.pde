Touch windowOrigin = null;
boolean drawingRectangle = false,
        canPlaceNewViewport = false;;
int placementX,
    placementY,
    placementCursorID,
    viewX = 0,
    viewY = 0,
    viewWidth = 0,
    viewHeight = 0;



void drawBackgroundZone( Zone z )
{
  background( 0 );
}


void touchDownBackgroundZone(Zone z, Touch t )
{
  System.out.println("DOWN");

  if ( !drawingRectangle )
  {
    drawingRectangle = true;
    placementX = t.x;
    placementY = t.y;
    placementCursorID = t.cursorID;
    System.out.println( "drawing Rectangle TRUE" );
  }
}

void touchBackgroundZone( Zone z )
{
  Touch[] touches = z.getTouches();
  Touch t = null;
  for ( Touch touch :  touches )
  {
    if ( touch.cursorID == placementCursorID )
    {
      t = touch;
    }
  }
  if ( t != null )
  {

    SMT.remove( "PlacementZone" );
    if ( SMT.get( "PlacementZone" ) == null )
    {
      spawnPlacementZone( t );
    }

  }

}

void spawnPlacementZone( Touch t )
{
  // System.out.println( "touchy: " + t.x + " " + t.y );
  int placementWidth  = Math.abs( placementX - t.x ),
      placementHeight = Math.abs( placementY - t.y );

  viewWidth    = placementWidth;
  viewHeight = placementHeight;

  if ( placementX > t.x && placementY > t.y )
  {
    // Dragged left and up
    SMT.add( new Zone( "PlacementZone",
                       t.x,
                       t.y,
                       placementWidth,
                       placementHeight )
            );
    // System.out.println( "Left and Up" );
    viewX = t.x;
    viewY = t.y;
  }
  else if ( placementX > t.x && placementY < t.y )
  {
    // Dragged left and down
    SMT.add( new Zone( "PlacementZone",
                       t.x,
                       placementY,
                       placementWidth,
                       placementHeight )
            );
    System.out.println( "Left and Down" );
    viewX = t.x;
    viewY = placementY;
  }
  else if ( placementX < t.x && placementY < t.y )
  {
    // Dragged right and down
    SMT.add( new Zone( "PlacementZone",
                       placementX,
                       placementY,
                       placementWidth,
                       placementHeight )
            );
    // System.out.println( "Right and Down" );
    viewX = placementX;
    viewY = placementY;
  }
  else if ( placementX < t.x && placementY > t.y )
  {
    // Dragged right and up
    SMT.add( new Zone( "PlacementZone",
                       placementX,
                       t.y,
                       placementWidth,
                       placementHeight )
            );
    // System.out.println( "Right and Up" );
    viewX = placementX;
    viewY = t.y;
  }
}

void drawPlacementZone( Zone z )
{
  if ( z.getWidth() < 400 || z.getHeight() < 400  )
  {
    // too small; show red
    fill( 255, 0, 0 );
    canPlaceNewViewport = false;
  }
  else
  {
    // acceptable size; show green
    fill( 0, 255, 0 );
    canPlaceNewViewport = true;
  }
  rect( 0, 0, z.getWidth(), z.getHeight() );
}

void touchUpBackgroundZone(Zone z, Touch t)
{
  // System.out.println( "Touch Up on BZ" );
  drawingRectangle = false;
  SMT.remove( "PlacementZone" );

  if ( canPlaceNewViewport )
  {
    Viewport view = new Viewport( nextViewPortID, viewX, viewY, viewWidth, viewHeight );
    nextViewPortID += 1;

    SMT.add( view );

    PImage waldoImageClone = waldo_images[curWaldoSet].get();
    ImageZone waldoImageZone;

    if ( view.getHeight() < view.getWidth() )
    {
      // Viewport is wider than tall (widescreen)
      int waldoHeight = (int)Math.round(view.getHeight()*0.8),
          waldoYMargin = (int)Math.round(view.getHeight()*0.1),
          waldoXMargin;

      waldoImageClone.resize( 0, waldoHeight );

      waldoXMargin = (int)Math.round( (view.getWidth() - waldoImageClone.width) / 2 );
      waldoImageZone = new ImageZone( "Waldo", waldoImageClone, waldoXMargin, waldoYMargin, waldoImageClone.width, waldoImageClone.height );
    }
    else
    {
      // Viewport is taller than wide (like a vertical smartphone)
      int waldoWidth  = (int)Math.round(view.getWidth()*0.8),
          waldoXMargin = (int)Math.round(view.getWidth()*0.1),
          waldoYMargin;

      waldoImageClone.resize( waldoWidth, 0 );

      waldoYMargin = (int)Math.round( (view.getHeight() - waldoImageClone.height) / 2 );
      waldoImageZone = new ImageZone( "Waldo", waldo_images[curWaldoSet].get(), waldoXMargin, waldoYMargin, waldoImageClone.width, waldoImageClone.height );
    }
    logger.logEvent( "New View: " + view.getName(),
                     "(X,Y) : (" + viewX + "," + viewY + ")",
                     "(W,H,AR) : (" + viewWidth + "," + viewHeight + "," + (float)viewWidth/(float)viewHeight );

    waldoImageZone.refreshResolution();
    view.addContent( waldoImageZone );
  }
}
