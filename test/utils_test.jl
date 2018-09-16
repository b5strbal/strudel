
module UtilsTest

using Donut.Utils: otherside

@test otherside(LEFT) == RIGHT
@test otherside(RIGHT) == LEFT
@test otherside(FORWARD) == BACKWARD
@test otherside(BACKWARD) == FORWARD
@test otherside(END) == START
@test otherside(START) == END


end