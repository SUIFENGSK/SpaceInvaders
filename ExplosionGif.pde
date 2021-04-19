class ExplosionGif
{
    private Gif explosion;
    private float x, y;
    public boolean status = true;
    public ExplosionGif (float x, float y, PApplet explosionGif)
    {
        explosion = new Gif (explosionGif, "Explosion.gif"); //Read and import the gif-image of the explosion
        explosion.play(); //Set the gif-image of the explosion's status to play
        this.x = x; //Get explosion coordinates
        this.y = y;
    }
    public void Display()
    {
        if (explosion.currentFrame()<25)
        {
            image(explosion, x, y, 120, 120);
        } else //If the gif-image of the current explosion has been played once, stop playing
        {
            explosion.stop();
            status = false;
        }
    }
}
