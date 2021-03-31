class ExplosionGif
{
    Gif explosion;
    float x, y;
    boolean status = true;
    ExplosionGif (float x, float y, PApplet explosionGif)
    {
        explosion = new Gif (explosionGif, "Explosion.gif");
        explosion.play();
        this.x = x;
        this.y = y;
    }
    void Display()
    {
        if (explosion.currentFrame()<25) 
        {
            image(explosion, x, y, 120, 120);
        } else 
        {
            explosion.stop();
            status = false;
        }
    }
}
