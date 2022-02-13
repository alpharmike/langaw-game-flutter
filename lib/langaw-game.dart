import 'dart:math';
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:langaw/views/home-view.dart';
import 'package:langaw/views/lost-view.dart';
import 'components/fly.dart';
import 'package:flutter/gestures.dart';
import 'package:langaw/components/backyard.dart';
import 'package:langaw/components/house-fly.dart';
import 'package:langaw/components/agile-fly.dart';
import 'package:langaw/components/drooler-fly.dart';
import 'package:langaw/components/hungry-fly.dart';
import 'package:langaw/components/macho-fly.dart';
import 'package:langaw/view.dart';
import 'package:langaw/components/start-button.dart';
import 'package:langaw/controllers/spawner.dart';
import 'package:langaw/components/credits-button.dart';
import 'package:langaw/components/help-button.dart';
import 'package:langaw/views/help-view.dart';
import 'package:langaw/views/credits-view.dart';
import 'package:langaw/components/score-display.dart';

class LangawGame extends Game {
  Size screenSize;
  double tileSize;
  List<Fly> flies;
  Random rnd;
  Backyard background;
  View activeView = View.Home;
  HomeView homeView;
  LostView lostView;
  StartButton startButton;
  FlySpawner spawner;
  HelpButton helpButton;
  CreditsButton creditsButton;
  HelpView helpView;
  CreditsView creditsView;
  int score;
  ScoreDisplay scoreDisplay;



  LangawGame() {
    initialize();
  }

  void initialize() async {
    flies = List<Fly>(); // flies = []
    rnd = Random();
    resize(await Flame.util.initialDimensions());
    background = Backyard(this);
    homeView = HomeView(this);
    lostView = LostView(this);
    helpView = HelpView(this);
    creditsView = CreditsView(this);
    spawner = FlySpawner(this);
    startButton = StartButton(this);
    helpButton = HelpButton(this);
    creditsButton = CreditsButton(this);
    scoreDisplay = ScoreDisplay(this);
    score = 0;
  }

  void spawnFly() {
    double x = rnd.nextDouble() * (screenSize.width - (tileSize * 2.025));
    double y = rnd.nextDouble() * (screenSize.height - (tileSize * 2.025));
    switch (rnd.nextInt(5)) {
      case 0:
        flies.add(HouseFly(game: this, x: x, y: y));
        break;
      case 1:
        flies.add(DroolerFly(game: this, x: x, y: y));
        break;
      case 2:
        flies.add(AgileFly(game: this, x: x, y: y));
        break;
      case 3:
        flies.add(MachoFly(game: this, x: x, y: y));
        break;
      case 4:
        flies.add(HungryFly(game: this, x: x, y: y));
        break;
    }
  }

  void render(Canvas canvas) {
//    Rect bgRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
//    Paint bgPaint = Paint();
//    bgPaint.color = Color(0xff576574);
//    canvas.drawRect(bgRect, bgPaint);
    background.render(canvas);
    if (activeView == View.Playing) scoreDisplay.render(canvas);
    flies.forEach((Fly fly) => fly.render(canvas));
    if (activeView == View.Home) {
      homeView.render(canvas);
    }
    if (activeView == View.Lost) {
      lostView.render(canvas);
    }
    if (activeView == View.Help) {
      helpView.render(canvas);
    }
    if (activeView == View.Credits) {
      creditsView.render(canvas);
    }
    if (activeView == View.Home || activeView == View.Lost) {
      startButton.render(canvas);
      helpButton.render(canvas);
      creditsButton.render(canvas);
    }
  }

  void update(double t) {
    flies.forEach((Fly fly) => fly.update(t));
    flies.removeWhere((Fly fly) => fly.isOffScreen);
    spawner.update(t);
    if (activeView == View.Playing) scoreDisplay.update(t);
  }

  void resize(Size size) {
    print("here");

    this.screenSize = size;
    tileSize = screenSize.width / 9;
  }

  void onTapDown(TapDownDetails d) {
    bool isHandled = false;

    if (!isHandled && startButton.rect.contains(d.globalPosition)) {
      if (activeView == View.Home || activeView == View.Lost) {
        startButton.onTapDown();
        isHandled = true;
      }
    }

    if (!isHandled && helpButton.rect.contains(d.globalPosition)) {
      if (activeView == View.Home || activeView == View.Lost) {
        helpButton.onTapDown();
        isHandled = true;
      }
    }

    if (!isHandled && creditsButton.rect.contains(d.globalPosition)) {
      if (activeView == View.Home || activeView == View.Lost) {
        creditsButton.onTapDown();
        isHandled = true;
      }
    }

    if (!isHandled && (activeView == View.Help || activeView == View.Credits)) {
      activeView = View.Home;
      isHandled = true;
    }

    if (!isHandled) {
      bool didHitAFly = false;
      flies.forEach((fly) {
        if (fly.flyRect.contains(d.globalPosition)) {
          fly.onTapDown();
          isHandled = true;
          didHitAFly = true;
        }
      });

      if (activeView == View.Playing && !didHitAFly) {
        activeView = View.Lost;
      }
    }
  }
}