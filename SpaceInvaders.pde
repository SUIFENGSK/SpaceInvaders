import uibooster.*;
import uibooster.components.*;
import uibooster.model.*;
import uibooster.model.formelements.*;
import uibooster.utils.*;
import gifAnimation.*;
import processing.sound.*;
Gif spaceAnimation;
SoundFile explosionBgm, spaceBgm;
Player player;
ArrayList < Enemy > enemy;
ArrayList < ExplosionGif > explosionGif;
ArrayList < Button > button;
int initEnemy = 100;
float enemySize = 40, playerSize = 70;
int remainingLife;
int score;
String userName = null;
StringList userTopListName = new StringList();
IntList userTopListScore = new IntList();
boolean isNewGame = true, initImport = true, initName = true, nameIsConfirmed = false, shipIsChanged = false;
String shipName;
UiBooster booster;
ListElement selectedElement;
int degreeOfDifficulty;
FilledForm form;
void setup()
{
    size(500, 900);
    GUIInit();
    GameInit();
}
void draw()
{
    if (remainingLife == 0 && mousePressed)
        {
        spaceBgm.stop();
        ResetGame();
        isNewGame = true;
        button.get(0).action = false;
        button.get(1).action = false;
        button.get(2).action = false;
        button.get(3).action = false;
        button.get(4).action = false;
        mousePressed = false;
    }
    if (!button.get(0).action && !button.get(1).action && !button.get(2).action && !button.get(3).action && !button.get(4).action) GUIStartLoop();
    else if (button.get(0).action) //new game
        {
        mousePressed = false;
        button.get(1).action = false;
        CreateUser();
        imageMode(CENTER);    
        frameRate(60);
        image(spaceAnimation, width / 2, height / 2, width, height); 
        if (remainingLife > 0) {
            player.Display();
            EnemyMove();
            PlayerMissileJudgment();
            EnemyMissileJudgment();
            CollideWithTheEnemy();
            DisplayInfo();
        } else {
            spaceBgm.amp(0.2);
            CalculateAndDisplayTheFinalResult();
        }
    } else if (button.get(1).action) //Personalized Settings
        {
        mousePressed = false;
        button.get(1).action = false;
        shipIsChanged = true;
        booster = new UiBooster();
    do {
            form = new UiBooster()
               .createForm("Your settings")
               .addList("Choose your ship", 
                new ListElement("Ship 1(Default ship)", "Green and strong", dataPath("PlayerShip01.png")), 
                new ListElement("Ship 2", "Green and strong", dataPath("PlayerShip02.png")), 
                new ListElement("Ship 3", "Green and strong", dataPath("PlayerShip03.png")), 
                new ListElement("Ship 4", "Green and strong", dataPath("PlayerShip04.png")))
               .addSlider("Difficulty settings", 1, 10, 5, 3, 1)
               .andWindow()
               .setSize(500, 625)
               .setUndecorated()
               .setPosition(width / 2 + 465, height / 2 - 250)
               .save()
               .show();
            if (form.getByLabel("Choose your ship").getValue() == null) new UiBooster().showErrorDialog("You must choose a spaceship!", "ERROR");
        } while(form.getByLabel("Choose your ship").getValue() == null);
        
        String value = form.getByLabel("Choose your ship").asString();
        String listValue = "";
        int count = 0;
        boolean record = false;
        //println(value);
        for (int i = 0; i < value.length(); i++)
        {
            if (value.charAt(i) == char(39)) {
                count++;
                record = true;
            }
            if (count == 2) break;
            if (record && value.charAt(i + 1)!= char(39))
            {
                listValue +=value.charAt(i + 1);
            }
        }
        println(listValue);
        if (listValue.equals("Ship 1(Default ship)")) shipName = "PlayerShip01";
        if (listValue.equals("Ship 2")) shipName = "PlayerShip02";
        if (listValue.equals("Ship 3")) shipName = "PlayerShip03";
        if (listValue.equals("Ship 4")) shipName = "PlayerShip04";
        player = new Player(playerSize, shipName);
        degreeOfDifficulty = form.getByLabel("Difficulty settings").asInt();
        //println(degreeOfDifficulty);
    } else if (button.get(2).action) //Leaderboard
        {
        mousePressed = false;
        button.get(2).action = false;
    } else if (button.get(3).action) //Help
        {
        mousePressed = false;
        button.get(3).action = false;
        booster = new UiBooster();
        booster.showPictures("My pictures",new String[] {
            dataPath("PlayerShip01.png"),
            dataPath("PlayerShip02.png"),
            dataPath("PlayerShip03.png")
            });
    } else if (button.get(4).action) //Exit
        {
        mousePressed = false;
        button.get(4).action = false;
        exit();
    }
}
void GUIInit()
{
    spaceAnimation = new Gif (this, "Space08.gif");
    spaceAnimation.loop();
    explosionBgm = new SoundFile(this, "Explosion.mp3");
    explosionBgm.amp(0.2);
    spaceBgm = new SoundFile(this, "Spacebgm.mp3");
    spaceBgm.amp(1);
    spaceBgm.loop();
    button = new ArrayList<Button>();
    button.add(new Button(width / 2, height * 2.7 / 8, "New Game"));
    button.add(new Button(width / 2, height * 3.45 / 8, "Personalized Settings"));
    button.add(new Button(width / 2, height * 4.2 / 8, "Leaderboard"));
    button.add(new Button(width / 2, height * 4.95 / 8, "Help"));
    button.add(new Button(width / 2, height * 5.7 / 8, "Exit"));
}
void GameInit()
{
    if (initImport) {
        ImportData();
        initImport = false;
    }
    remainingLife = 10;
    score = 0;
    player = new Player(playerSize);
    enemy = new ArrayList<Enemy>();
    explosionGif = new ArrayList < ExplosionGif > ();
    for (int i = 0; i < initEnemy; i++) {
        enemy.add(new Enemy(0 - i * 70, enemySize));
    }
    enemy.get(0).yMove = true;
}
void GUIStartLoop()
{
    imageMode(CENTER);  
    image(spaceAnimation, width / 2, height / 2, width, height);
    fill(255);
    stroke(255);
    textAlign(CENTER);
    textSize(60);
    textMode(MODEL);
    text("Space Invaders", width / 2, height * 1.5 / 8);
    textSize(20);
    text("Developed by Shuokai", width / 2, height * 7 / 8);
    for (int i = 0; i < button.size(); i++)
        {
        button.get(i).createButton();
    }
}
void EnemyMove()
{
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
            enemy.get(0).yMove = true;
        }
        //println(i, enemy.get(0).yMove);
    }
}
void PlayerMissileJudgment()
{
    for (int i = 0; i < player.missile.size(); i++)
        {
        for (int j = 0; j < enemy.size(); j++)
        {
            if (player.missile.get(i).x>enemy.get(j).x - enemySize / 2 && player.missile.get(i).x<enemy.get(j).x + enemySize / 2 &&
                player.missile.get(i).y>enemy.get(j).y - enemySize / 2 && player.missile.get(i).y<enemy.get(j).y + enemySize / 2)
            {
                explosionGif.add(new ExplosionGif (player.missile.get(i).x, player.missile.get(i).y, this));
                    explosionBgm.play();
                enemy.remove(j);
                enemy.get(0).yMove = true;
                player.missile.remove(i);
                score +=100;
                break;
            }
        }
    }
    DisplayExplosion();
}
void EnemyMissileJudgment()
{
    for (int i = 0; i < enemy.size(); i++)
        {
        for (int j = 0; j < enemy.get(i).missile.size(); j++)
        {
            if (enemy.get(i).missile.get(j).x>player.x - playerSize / 2 && enemy.get(i).missile.get(j).x<player.x + playerSize / 2 &&
                enemy.get(i).missile.get(j).y>player.y - playerSize / 2 && enemy.get(i).missile.get(j).y<player.y + playerSize / 2)
            {
                explosionGif.add(new ExplosionGif (enemy.get(i).missile.get(j).x, enemy.get(i).missile.get(j).y, this));
                    explosionBgm.play();
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
void CollideWithTheEnemy()
{
    for (int i = 0; i < enemy.size(); i++)
        {
        if (((enemy.get(i).x + enemySize / 2>player.x - playerSize / 2 && enemy.get(i).x + enemySize / 2<player.x + playerSize / 2) ||
           (enemy.get(i).x - enemySize / 2>player.x - playerSize / 2 && enemy.get(i).x - enemySize / 2<player.x + playerSize / 2)) &&
           ((enemy.get(i).y + enemySize / 2>player.y - playerSize / 2 && enemy.get(i).y + enemySize / 2<player.y + playerSize / 2) ||
           (enemy.get(i).y - enemySize / 2>player.y - playerSize / 2 && enemy.get(i).y - enemySize / 2<player.y + playerSize / 2)))
        {
            explosionGif.add(new ExplosionGif ((enemy.get(i).x + player.x) / 2,(enemy.get(i).y + player.y) / 2, this));
                explosionBgm.play();
            enemy.remove(i);
            enemy.get(0).yMove = true;
            remainingLife--;
            score -=50;
            if (score < 0) score = 0;
            break;
        }
    }
    DisplayExplosion();
}
void DisplayInfo()
{
    fill(255);
    textSize(16);
    textAlign(LEFT);
    text("User:", 365, 20);
    text(userName, 430, 20);
    text("Life:", 365, 40);
    text(remainingLife, 430, 40);
    text("Score:", 365, 60);
    text(score, 430, 60);
}
void CalculateAndDisplayTheFinalResult()
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
        SaveData();
    }
    fill(255);
    textAlign(CENTER);
    textSize(65);
    text("GAME OVER!", width / 2, height * 1.5 / 8);
    textAlign(LEFT);
    textSize(30);
    text("Name:", width / 2 - 150, height * 2.5 / 8);
    text(userName, width / 2, height * 2.5 / 8);
    text("Score:", width / 2 - 150, height * 3 / 8);
    text(score, width / 2, height * 3 / 8);
    textAlign(CENTER);
    textSize(30);
    text("Leaderboard - TOP 3", width / 2, height * 4.25 / 8);
    int displayNum;
    if (userTopListName.size()>= 3) displayNum = 3;
    else displayNum = userTopListName.size();
    for (int i = 0; i < displayNum; i++)
        {
        textSize(25);
        text(userTopListName.get(i), width / 2 - 100, height * (4.25 + (i + 1) * 0.5) / 8);
        text(userTopListScore.get(i), width / 2 + 60, height * (4.25 + (i + 1) * 0.5) / 8);
    }
    textSize(20);
    text("Click the mouse to restart the game", width / 2, height * 7 / 8);
}
void DisplayExplosion()
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
void ResetGame()
{
    enemy.clear();
    setup();
}
void ImportData()
{
    JSONArray userData = loadJSONArray("data/userData.json");
    for (int i = 0; i < userData.size(); i++)
        {
        userTopListName.append(userData.getJSONObject(i).getString("name"));
        userTopListScore.append(userData.getJSONObject(i).getInt("score"));
    }
}
void SaveData()
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
void CreateUser()
{
    while((userTopListName.hasValue(userName) || userName == null) && initName && !nameIsConfirmed)
        {
        userName = new UiBooster().showTextInputDialog("Please enter your name:");
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
