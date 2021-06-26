#ifndef BREAKOUT_INC
#define BREAKOUT_INC

#define txBallPosVel   int2(0,0)
#define txPaddlePos    int2(1,0)
#define txPoints       int2(2,0)
#define txState        int2(3,0)
#define txLastHit      int2(4,0)
#define txCalibrate    int2(5,0)
#define txTouch        int2(6,0)
#define txStart        int2(7,0)
#define txBricks       int4(0,1,13,12)

#define ballRadius   0.035
#define paddleSize   0.25
#define paddleWidth  0.06
#define paddlePosY  -0.90
#define paddle2PosY -0.90
#define brickW       0.145
#define brickH       0.06666666666

#define WAIT_INPUT      0
#define CAL_GUIDE       1
#define CAL_VAL         2
#define CAL_DONE        3

#define GAME_START      1
#define GAME_END        2

#endif