import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import uibooster.*; 
import uibooster.components.*; 
import uibooster.model.*; 
import uibooster.model.formelements.*; 
import uibooster.utils.*; 
import gifAnimation.*; 
import processing.sound.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class SpaceInvaders extends PApplet {








Gif spaceAnimation;
SoundFile explosionBgm, spaceBgm, itemBgm;
Player player;
ArrayList < Enemy > enemy;
ArrayList < ExplosionGif > explosionGif;
ArrayList < Button > button;
ArrayList < Item > item;
int initEnemy;
float enemySize = 40, playerSize = 70;
int remainingLife;
int score;
String userName = null;
StringList userTopListName = new StringList();
IntList userTopListScore = new IntList();
boolean isNewGame = true, initImport = true, initName = true, nameIsConfirmed = false, shipIsChanged = false;
boolean personalizedSettings = false, exitIsConfirmed = false, isFirstTime=true;
String shipName, controllerMode = "Keyboard Mode";
UiBooster booster;
ListElement selectedElement;
int degreeOfDifficulty = 5,defaultDegreeOfDifficulty = 5;
FilledForm form;
ProgressDialog dialog;
Button exitButton;
public void setup()
{
    
    if(isFirstTime){
    WaitingDialog waitingDialog;
    booster = new UiBooster();
    waitingDialog = booster.showWaitingDialog("Starting", "Starting program");
    //waitingDialog.setLargeMessage("Loading image...\nLoading animation...\nLoading background music...\nInitializing the game interface...");
    delay(1500);
    waitingDialog.close();
    dialog = new UiBooster().showProgressDialog("Please wait", "Waiting", 0, 120);
    dialog.setProgress(10);
    dialog.setMessage("Starting program...");
    GUIInit();
    dialog.setProgress(70);
    dialog.setMessage("Initializing game data...");
    GameInit();
    dialog.setProgress(120);
    dialog.setMessage("Ready!");
    delay(1000);
    dialog.close();
    }
    else GameInit();
}
public void draw()
{
    if (!button.get(0).action && !button.get(1).action && !button.get(2).action && !button.get(3).action && !button.get(4).action) GUIStartLoop();
    else if (button.get(0).action) //new game
        {
        //mousePressed = false;
        //button.get(1).action = false;
        CreateUser();
        imageMode(CENTER);    
        frameRate(60);
        image(spaceAnimation, width / 2, height / 2, width, height); 
        if (remainingLife > 0 && enemy.size()>0) {        
            player.Display();
            DisplayAndCheckItem();
            EnemyMove();
            PlayerMissileJudgment();
            EnemyMissileJudgment();
            CollideWithTheEnemy();
            CheckEnemyIsAlive();
            DisplayInfo();
            ExitGameButtonListener();
        } else {
            spaceBgm.amp(0.2f);
            CalculateAndDisplayTheFinalResult();
        }
    } else if (button.get(1).action) //Personalized Settings
        {
        mousePressed = false;
        button.get(1).action = false;
        personalizedSettings = true;
        shipIsChanged = true;
        booster = new UiBooster();
    do {
            form = new UiBooster()
               .createForm("Personalized settings")
               .addSelection("Controller mode", "Keyboard Mode", "Mouse Mode")
               .addList("Choose your ship", 
                new ListElement("Ship 1 (Default ship)", "Green and strong", dataPath("PlayerShip01.png")), 
                new ListElement("Ship 2", "Green and strong", dataPath("PlayerShip02.png")), 
                new ListElement("Ship 3", "Green and strong", dataPath("PlayerShip03.png")), 
                new ListElement("Ship 4", "Green and strong", dataPath("PlayerShip04.png")))
               .addSlider("Number of enemies (Default number of enemies is 50)", 50, 500, 50, 50, 9)
               .addSlider("Difficulty settings (Default degree of difficulty is 5)", 1, 10, degreeOfDifficulty, 3, 1)
               .andWindow()
               .setSize(500, 725)
               .setUndecorated()
               .setPosition(displayWidth / 2 - 500 / 2,displayHeight / 2 - 725 / 2)
               .save()
               .show();
            if (form.getByLabel("Choose your ship").getValue() == null) new UiBooster().showErrorDialog("You must choose a spaceship!", "ERROR");
        } while(form.getByLabel("Choose your ship").getValue() == null);
        controllerMode = form.getByLabel("Controller Mode").asString();
        String value = form.getByLabel("Choose your ship").asString();
        String listValue = "";
        int count = 0;
        boolean record = false;
        //println(value);
        for (int i = 0; i < value.length(); i++)
        {
            if (value.charAt(i) == PApplet.parseChar(39)) {
                count++;
                record = true;
            }
            if (count == 2) break;
            if (record && value.charAt(i + 1)!= PApplet.parseChar(39))
            {
                listValue +=value.charAt(i + 1);
            }
        }
        //println(listValue);
        if (listValue.equals("Ship 1 (Default ship)")) shipName = "PlayerShip01";
        if (listValue.equals("Ship 2")) shipName = "PlayerShip02";
        if (listValue.equals("Ship 3")) shipName = "PlayerShip03";
        if (listValue.equals("Ship 4")) shipName = "PlayerShip04";
        player = new Player(playerSize, shipName,controllerMode);
        initEnemy = form.getByLabel("Number of enemies (Default number of enemies is 50)").asInt();
        degreeOfDifficulty = form.getByLabel("Difficulty settings (Default degree of difficulty is 5)").asInt();
        enemy.clear();
        for (int i = 0; i < initEnemy; i++) {
            enemy.add(new Enemy(0 - i * 70, enemySize));
            enemy.get(i).xSpeed = 3 + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.2f;
            enemy.get(i).ySpeed = 3 + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.2f;
        }
        enemy.get(0).yMove = true;
        //println(degreeOfDifficulty);
    } else if (button.get(2).action) //Leaderboard
        {
        mousePressed = false;
        button.get(2).action = false;
        CalculateResult();
        int displayNum;
        String textData = "Leaderboard - TOP 5\n\n";
        if (userTopListName.size()>= 5) displayNum = 5;
        else displayNum = userTopListName.size();
        for (int i = 0; i < displayNum; i++)
        {
            textData +=userTopListName.get(i);
            textData +=": ";
            textData +=userTopListScore.get(i);
            textData +="\n\n";            
        }
        booster = new UiBooster();
        booster.showInfoDialog(textData);
        
    } else if (button.get(3).action) //Help
        {
        mousePressed = false;
        button.get(3).action = false;
        booster = new UiBooster();
        booster.showPictures("Help",new String[] {
            dataPath("PlayerShip01.png"),
                dataPath("PlayerShip02.png"),
                dataPath("PlayerShip03.png")});
    } else if (button.get(4).action) //Exit
        {
        mousePressed = false;
        button.get(4).action = false;
        exit();
    }
    if ((remainingLife == 0 || enemy.size() == 0) && mousePressed) //init Game
    {
        ResetGame();        
    }
}
public void GUIInit()
{
    spaceAnimation = new Gif (this, "Space08.gif");
    spaceAnimation.loop();
    dialog.setProgress(30);
    dialog.setMessage("Loading image and animation...");
    explosionBgm = new SoundFile(this, "Explosion.mp3");
    explosionBgm.amp(0.5f);
    spaceBgm = new SoundFile(this, "Spacebgm.mp3");
    spaceBgm.amp(1);
    spaceBgm.loop();
    itemBgm = new SoundFile(this, "Item.mp3");
    itemBgm.amp(0.5f);
    dialog.setProgress(50);
    dialog.setMessage("Initializing the game interface...");
    button = new ArrayList<Button>();
    button.add(new Button(width / 2, height * 2.7f / 8, "New Game",30));
    button.add(new Button(width / 2, height * 3.45f / 8, "Personalized Settings",30));
    button.add(new Button(width / 2, height * 4.2f / 8, "Leaderboard",30));
    button.add(new Button(width / 2, height * 4.95f / 8, "Help",30));
    button.add(new Button(width / 2, height * 5.7f / 8, "Exit",30));
    exitButton = new Button(30,20,"Exit",16);
}
public void GameInit()
{
    if (initImport) {
        ImportData();
        initImport = false;
    }
    remainingLife = 10;
    score = 0;
    if (!personalizedSettings) 
    {
        player = new Player(playerSize,controllerMode);
        initEnemy = 50;
    }
    else player = new Player(playerSize,shipName,controllerMode);
    enemy = new ArrayList<Enemy>();
    item = new ArrayList<Item>();
    explosionGif = new ArrayList < ExplosionGif > ();
    for (int i = 0; i < initEnemy; i++) {
        enemy.add(new Enemy(0 - i * 70, enemySize));
        if (personalizedSettings)
        {
            enemy.get(i).xSpeed = 3 + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.2f;
            enemy.get(i).ySpeed = 3 + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.2f;
        }
    }
    enemy.get(0).yMove = true;
}
public void GUIStartLoop()
{
    spaceBgm.amp(1);
    imageMode(CENTER);  
    image(spaceAnimation, width / 2, height / 2, width, height);
    fill(255);
    stroke(255);
    textAlign(CENTER);
    textSize(60);
    textMode(MODEL);
    text("Space Invaders", width / 2, height * 1.5f / 8);
    textSize(20);
    text("Developed by Shuokai", width / 2, height * 7 / 8);
    for (int i = 0; i < button.size(); i++) {
        button.get(i).createButton();
    }
}
public void DisplayAndCheckItem()
{
    //println(player.missileUpgrade);
    if (random(0, 1)<0.003f - (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.0005f) 
    {
        item.add(new Item(random(0,1)));
    }
    for (int i = 0;i < item.size();i++)
    {
        item.get(i).Move();
        if (item.get(i).y>height + item.get(i).itemSize) item.remove(i);
        if (item.size() == 0) break;
        if (item.get(i).x>player.x - playerSize / 2 && item.get(i).x<player.x + playerSize / 2 &&
            item.get(i).y>player.y - playerSize / 2 && item.get(i).y<player.y + playerSize / 2)
            {
            if (item.get(i).itemType == "LifeUp") 
            {
                remainingLife++;
                itemBgm.play();
            }
            else if (item.get(i).itemType == "MissileUp")
            {
                player.missileUpgrade +=40;
                itemBgm.play();
            }
            else if (item.get(i).itemType == "UniqueSkill")
            {
                itemBgm.play();
                for (int j = enemy.size() - 1;j >= 0;j--)
                {
                    if (enemy.get(j).y>0 && enemy.get(j).y<height + enemySize)
                    {
                        explosionBgm.play();
                        explosionGif.add(new ExplosionGif (enemy.get(j).x, enemy.get(j).y, this));                            
                        enemy.remove(j);
                        score +=100;
                    }
                }
            }
            item.remove(i);
        }        
    } 
}
public void EnemyMove()
{
    if (enemy.size() == 0) return;
    else enemy.get(0).yMove = true;
    for (int i = 0; i < enemy.size(); i++) 
        {
        //Prevent collision
        for (int j = 0; j < enemy.size() - 1; j++)
        {
            if (enemy.get(j).y - enemy.get(j + 1).y>50) {
                enemy.get(j + 1).yMove = true;
            } else
                enemy.get(j + 1).yMove = false;
        }
        //Move
        enemy.get(i).Move();
        if (enemy.get(i).y>height + enemySize)
        {
            enemy.remove(i);
        }
        //println(i, enemy.get(0).yMove);
    }
}
public void CheckEnemyIsAlive()
{
    for (int i = 0;i < enemy.size();i++)
    {
        if (enemy.get(i).isDestroyed && enemy.get(i).missile.size() == 0) enemy.remove(i);
    }
}
public void PlayerMissileJudgment()
{
    for (int i = 0; i < player.missile.size(); i++)
        {
        for (int j = 0; j < enemy.size(); j++)
        {
            if (player.missile.get(i).x>enemy.get(j).x - enemySize / 2 && player.missile.get(i).x<enemy.get(j).x + enemySize / 2 &&
                player.missile.get(i).y>enemy.get(j).y - enemySize / 2 && player.missile.get(i).y<enemy.get(j).y + enemySize / 2)
            {
                explosionBgm.play();
                explosionGif.add(new ExplosionGif (player.missile.get(i).x, player.missile.get(i).y, this));   
                enemy.get(j).isDestroyed = true;
                enemy.get(j).y =- height;
                player.missile.remove(i);
                score +=100;
                //if (enemy.size() == 0) break;
                //enemy.get(0).yMove = true;                
                break;
            }
        }
    }
    DisplayExplosion();
}
public void EnemyMissileJudgment()
{
    for (int i = 0; i < enemy.size(); i++)
        {
        for (int j = 0; j < enemy.get(i).missile.size(); j++)
        {
            if (enemy.get(i).missile.get(j).x>player.x - playerSize / 2 && enemy.get(i).missile.get(j).x<player.x + playerSize / 2 &&
                enemy.get(i).missile.get(j).y>player.y - playerSize / 2 && enemy.get(i).missile.get(j).y<player.y + playerSize / 2)
            {
                explosionBgm.play();
                explosionGif.add(new ExplosionGif (enemy.get(i).missile.get(j).x, enemy.get(i).missile.get(j).y, this));
                enemy.get(i).missile.remove(j);
                remainingLife--;
                score -=50;
                if (score < 0) score = 0;
                break;
            }
        }
    }
    DisplayExplosion();
}
public void CollideWithTheEnemy()
{
    for (int i = 0; i < enemy.size(); i++)
        {
        if (((enemy.get(i).x + enemySize / 2>player.x - playerSize / 2 && enemy.get(i).x + enemySize / 2<player.x + playerSize / 2) ||
           (enemy.get(i).x - enemySize / 2>player.x - playerSize / 2 && enemy.get(i).x - enemySize / 2<player.x + playerSize / 2)) &&
           ((enemy.get(i).y + enemySize / 2>player.y - playerSize / 2 && enemy.get(i).y + enemySize / 2<player.y + playerSize / 2) ||
           (enemy.get(i).y - enemySize / 2>player.y - playerSize / 2 && enemy.get(i).y - enemySize / 2<player.y + playerSize / 2)))
        {
            explosionBgm.play();
            explosionGif.add(new ExplosionGif ((enemy.get(i).x + player.x) / 2,(enemy.get(i).y + player.y) / 2, this));
            enemy.get(i).isDestroyed = true;
            enemy.get(i).y =- height;
            remainingLife--;
            score -=50;
            if (score < 0) score = 0;
            if (enemy.size() == 0) break;
            enemy.get(0).yMove = true;
            break;
        }
    }
    DisplayExplosion();
}
public void DisplayInfo()
{
    fill(255);
    textSize(16);
    textAlign(LEFT);
    text("User:", width * 6 / 8, 20);
    text(userName, width * 7 / 8, 20);
    text("Life:", width * 6 / 8, 40);
    text(remainingLife, width * 7 / 8, 40);
    text("Score:", width * 6 / 8, 60);
    text(score, width * 7 / 8, 60);
    text("Enemy:", width * 6 / 8, 80);
    text(enemy.size(), width * 7 / 8, 80);
}
public void CalculateAndDisplayTheFinalResult()
{
    if (isNewGame) {
        isNewGame = false;
        if (!userTopListName.hasValue(userName)) 
        {
            userTopListName.append(userName);
            userTopListScore.append(score);
        } else
        {
            for (int i = 0; i < userTopListName.size(); i++) 
            {
                if (userName.equals(userTopListName.get(i)) == true)
                {
                    if (score > userTopListScore.get(i)) 
                        userTopListScore.set(i, score);
                    break;
                }
            }
        }
        CalculateResult();
        SaveData();
    }
    fill(255);
    textAlign(CENTER);
    textSize(65);
    if (enemy.size()>0) text("GAME OVER!", width / 2, height * 1.5f / 8);
    else text("You Win!!!", width / 2, height * 1.5f / 8);
    textAlign(LEFT);
    textSize(30);
    text("Name:", width / 2 - 120, height * 2.5f / 8);
    text(userName, width / 2 + 30, height * 2.5f / 8);
    text("Score:", width / 2 - 120, height * 3 / 8);
    text(score, width / 2 + 30, height * 3 / 8);
    textAlign(CENTER);
    textSize(30);
    text("Leaderboard - TOP 3", width / 2, height * 4.25f / 8);
    int displayNum;
    if (userTopListName.size()>= 3) displayNum = 3;
    else displayNum = userTopListName.size();
    for (int i = 0; i < displayNum; i++)
        {
        textSize(25);
        text(userTopListName.get(i), width / 2 - 100, height * (4.25f + (i + 1) * 0.5f) / 8);
        text(userTopListScore.get(i), width / 2 + 60, height * (4.25f + (i + 1) * 0.5f) / 8);
    }
    textSize(20);
    text("Click the mouse to restart the game", width / 2, height * 7 / 8);
}
public void DisplayExplosion()
{
    for (int i = 0; i < explosionGif.size(); i++)
        {
        explosionGif.get(i).Display();
        if (!explosionGif.get(i).status)
        {
            explosionGif.remove(i);
        }
    }
}
public void ResetGame()
{
    enemy.clear();
    item.clear();
    //spaceBgm.stop();
    isNewGame = true;
    button.get(0).action = false;
    button.get(1).action = false;
    button.get(2).action = false;
    button.get(3).action = false;
    button.get(4).action = false;
    isFirstTime=false;
    mousePressed = false;
    setup();
}
public void ImportData()
{
    JSONArray userData = loadJSONArray("data/userData.json");
    for (int i = 0; i < userData.size(); i++)
        {
        userTopListName.append(userData.getJSONObject(i).getString("name"));
        userTopListScore.append(userData.getJSONObject(i).getInt("score"));
    }
}
public void SaveData()
{
    JSONArray userNewData = new JSONArray();
    for (int i = 0; i < userTopListName.size(); i++)
        {
        JSONObject userDataTemp = new JSONObject();
        userDataTemp.setString("name", userTopListName.get(i));
        userDataTemp.setFloat("score", userTopListScore.get(i));
        userNewData.setJSONObject(i, userDataTemp);
    }
    saveJSONArray(userNewData, "data/userData.json");
}
public void CreateUser()
{
    while((userTopListName.hasValue(userName) || userName == null) && initName && !nameIsConfirmed)
        {
        userName = new UiBooster().showTextInputDialog("Please enter your name:");
        if (userName == null || userName.equals("")) new UiBooster().showErrorDialog("The name is not allowed to be empty!", "ERROR");
        if (userTopListName.hasValue(userName) && !userName.equals(""))
        {
            booster = new UiBooster();
            booster.showConfirmDialog(
                "If you are the owner of this name, please click Yes and log in to the game with this name, otherwise please click No and enter your new name!", 
                "Detected the same name!", 
                new Runnable() {
                public void run() {
                    nameIsConfirmed = true;
                }
            }
            , 
            new Runnable() {
                public void run() {
                    nameIsConfirmed = false;
                }
            }
           );
        }
    }
    initName = false;
}
public void CalculateResult()
{
    int tempScore;
    String tempName;
    for (int i = 0; i < userTopListName.size() - 1; i++) 
        {
        for (int j = 0; j < userTopListName.size() - 1 - i; j++) 
            {
            if (userTopListScore.get(j) < userTopListScore.get(j + 1)) 
                {
                tempScore = userTopListScore.get(j);
                userTopListScore.set(j, userTopListScore.get(j + 1)); 
                userTopListScore.set(j + 1, tempScore); 
                tempName = userTopListName.get(j);
                userTopListName.set(j, userTopListName.get(j + 1));
                userTopListName.set(j + 1, tempName);
            }
        }
    }
}
public void ExitGameButtonListener()
{
    exitButton.createButton();
    if (exitButton.action)
    {
        mousePressed = false;
        exitButton.action = false;
        booster = new UiBooster();
        booster.showConfirmDialog(
            "Are you sure to exit the game? Please note that your game data will not be saved!",
            "Exit Game",
            new Runnable() {
            public void run() {
                exitIsConfirmed = true;
            }
        } ,
        new Runnable() {
            public void run() {
                exitIsConfirmed = false;
            }
        }
       );
    }
    if (exitIsConfirmed) 
    {
        ResetGame();
        exitIsConfirmed = false;
    }
}
class Button 
{
    float x, y;
    String text;
    float buttonWidth = 200, buttonHeight = 80;
    float R = 225, G = 225, B = 225;
    boolean action = false;
    float textSize;
    Button(float x, float y, String text, float textSize) 
    {
        this.x = x;
        this.y = y;
        this.text = text;
        this.textSize=textSize;
    }
    public void createButton()
    {
        pushMatrix();
        stroke(0);
        render();
        rectMode(CENTER);
        fill(R, G, B);
        //rect(x, y, buttonWidth, buttonHeight);
        textSize(textSize);
        textAlign(CENTER, CENTER);
        text(text, x, y);
        popMatrix();
        checkButton();
        buttonAction();
    }
    public void render() 
    {
        if (mouseX > x - buttonWidth / 2 && mouseX < x + buttonWidth / 2 && mouseY > y - buttonHeight / 2 && mouseY < y + buttonHeight / 2) {
            R = 138;
            G = 217;
            B = 78;
        } else {
            R = 225;
            G = 225;
            B = 225;
        }
    }
    public void checkButton() 
    {
        if (mouseX > x - buttonWidth / 2 && mouseX < x + buttonWidth / 2 && mouseY > y - buttonHeight / 2 && mouseY < y + buttonHeight / 2) {
           if (mousePressed && action == false)
            {
                action = true;
        } else
                action = false;
        }
    }
    public void buttonAction() 
    {
        if (action) {
            //println("hello");
        }
    }
}
class Enemy
{
    float enemySize;
    float x, y;
    float xSpeed = 3, ySpeed = 3;
    int time = 0;
    int lastTime = 0;
    boolean xyDirection, yMove = false, isDestroyed = false;
    ArrayList<Missile> missile = new ArrayList<Missile>();
    Pic enemyShipImg = new Pic("EnemyShip");
    Enemy(float y, float enemySize)
    {
        x = random(enemySize / 2 + 10, width - enemySize / 2 - 10);
        this.y = y;
        this.enemySize = enemySize;
    }
    public void Move()
    {
        if (!isDestroyed) 
        {
            time = millis() - lastTime;
            imageMode(CENTER);
            enemyShipImg.display(x,y,enemySize,enemySize);
            if (time > 500) {
                lastTime = millis();
                if (random(0, 1)<0.5f + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.06f) xyDirection = false; //y-direction
                else xyDirection = true; //x-direction
            }
            if (xyDirection) x += xSpeed;
            else if (yMove && !xyDirection) 
            {
                y +=ySpeed;
            } else
            {
                x +=xSpeed;
            }
            //println(x);
            if (x > width - enemySize / 2 || x < enemySize / 2) xSpeed =- xSpeed;
            if (x > width - enemySize / 2) x = width - enemySize / 2;
            if (x < enemySize / 2) x = enemySize / 2;
            if (y > 0 && y < height - 30) 
            {
                MissileAdd();
            }
        }
        MissileLaunch();
        
    }
    public void MissileAdd()
    {
        if (!isDestroyed && random(0, 1)<0.01f + (degreeOfDifficulty - defaultDegreeOfDifficulty) * 0.001f) 
        {
            missile.add(new Missile(x, y, "ENEMY"));
        }        
    }
    public void MissileLaunch()
    {
        if (missile.size()>0) {
            for (int i = 0; i < missile.size(); i++) 
            {
                missile.get(i).Launch();
                if (missile.get(i).y>height) 
                {
                    missile.remove(i);
                }
            }
        }
        //println(missile.size());F
    }
}
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
    public void Display()
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
class Item
{
    float itemSize = 30;
    float x, y;
    float ySpeed = 3;
    Pic itemImg;
    boolean status = false;
    String itemType;
    Item(float randomNum)
    {
        x = random(itemSize / 2 + 10, width - itemSize / 2 - 10);
        y = 0;
        if (randomNum < 0.45f) 
        {
            itemImg = new Pic("LifeUp");
            itemType = "LifeUp";
        }
        if (randomNum >= 0.45f && randomNum < 0.9f) 
        {
            itemImg = new Pic("MissileUp");
            itemType = "MissileUp";
        }
        
        if (randomNum >=0.9f) 
        {
            itemImg = new Pic("UniqueSkill");
            itemType = "UniqueSkill";
        }
    }
    public void Move()
    {
        imageMode(CENTER);
        itemImg.display(x,y,itemSize,itemSize);
        y +=ySpeed;
    }
}
class Missile
{
    float x, y;
    float missileSpeed;
    String type;
    Pic playerMissile = new Pic("PlayerMissile");
    Pic enemyMissile = new Pic("EnemyMissile");
    Missile(float x, float y, String type)
    {
        this.x = x;
        this.type = type;
        if (type == "PLAYER")
        {
            missileSpeed = 10;
            this.y = y - 10;
        }
        if (type == "ENEMY") 
        {
            missileSpeed =- 10;
            this.y = y + 10;
        }
    }
    public void Launch()
    {
        if (type == "PLAYER")
        {
            imageMode(CENTER);
            playerMissile.display(x, y, 20, 30);
        }
        if (type == "ENEMY")
        {
            imageMode(CENTER);
            enemyMissile.display(x, y, 20, 30);
        }
        y -=missileSpeed;
    }
}
class Pic {
    PImage img;
    int k;
    Pic(String filename) 
    {
        img = loadImage(filename + ".png");
    }
    Pic(String filename, int temp) 
    {
        k = temp;
        img = loadImage(filename + k + ".png");
    }
    public void display(float x, float y, float pWidth, float pHeight)
    {
        imageMode(CENTER);
        image(img, x, y, pWidth, pHeight); //<>//
    }
}
class Player
{
    float x = width / 2;
    float y = height * 7 / 8;
    float moveSpeed = 10;
    float playerSize;
    int time = 0;
    int lastTime = 0;
    ArrayList<Missile> missile = new ArrayList<Missile>();
    Pic playerShipImg;
    int missileUpgrade = 0;
    String controllerMode;
    Player(float playerSize, String shipName, String controllerMode) 
    {
        this.playerSize = playerSize;
        this.controllerMode=controllerMode;
        playerShipImg = new Pic(shipName);
    }
    Player(float playerSize, String controllerMode) 
    {
        this.playerSize = playerSize;
        this.controllerMode=controllerMode;
        playerShipImg = new Pic("PlayerShip01");
    }
    public void Display()
    {
        imageMode(CENTER);
        playerShipImg.display(x, y, playerSize, playerSize);
        if(controllerMode.equals("Keyboard Mode")) KeyboardMove();
        if(controllerMode.equals("Mouse Mode")) MouseMove();
        MissileLaunch();
    }
    public void KeyboardMove()
    {
        if (keyPressed && keyCode == UP) 
        {
            y -=moveSpeed;
            keyCode = 0;
        }
        if (keyPressed && keyCode == DOWN) 
        {
            y +=moveSpeed;
            keyCode = 0;
        }
        if (keyPressed && keyCode == LEFT) 
        {
            x -=moveSpeed;
            keyCode = 0;
        }
        if (keyPressed && keyCode == RIGHT) 
        {
            x +=moveSpeed;
            keyCode = 0;
        }
        if (x > width - playerSize / 2) x = width - playerSize / 2;
        if (x < playerSize / 2) x = playerSize / 2;
        if (y > height - playerSize / 2) y = height - playerSize / 2;
        if (y < playerSize / 2) y = playerSize / 2;
    }
    public void MouseMove()
    {
        x=mouseX;
        y=mouseY;
        if (x > width - playerSize / 2) x = width - playerSize / 2;
        if (x < playerSize / 2) x = playerSize / 2;
        if (y > height - playerSize / 2) y = height - playerSize / 2;
        if (y < playerSize / 2) y = playerSize / 2;
    }
    public void MissileLaunch()
    {
        time = millis() - lastTime;
        if (missileUpgrade > 400) missileUpgrade = 400;
        if (time > 700 - missileUpgrade) {
            lastTime = millis();
            missile.add(new Missile(x, y, "PLAYER"));
        }
        /*
        if (keyPressed && key==' ') 
    {
        key=0;
        missile.add(new Missile(x, y, "PLAYER"));
    }
        */
        if (missile.size()>0) {
            for (int i = 0; i < missile.size(); i++) 
            {
                missile.get(i).Launch();
                if (missile.get(i).y<0) 
                {
                    missile.remove(i);
                }
            }
        }
        //println(missile.size());
    }
}
  public void settings() {  size(700, 900); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "SpaceInvaders" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
