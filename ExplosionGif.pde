class ExplosionGif
{
    Gif explosion;
    float x, y;
    boolean status = true;
    ExplosionGif (float x, float y, PApplet explosionGif)
    {
        explosion = new Gif (explosionGif, "Explosion.gif"); //Read and import the gif-image of the explosion
        explosion.play(); //Set the gif-image of the explosion's status to play
        this.x = x; //Get explosion coordinates
        this.y = y;
    }
    void Display()
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
