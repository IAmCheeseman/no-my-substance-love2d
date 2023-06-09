local bow = {
    sprite = Sprite.new("entities/enemies/archer/bow.png", 2, 0),
    target = nil,
}


function bow:fire()
    self.sprite.frame = 2
end

function bow:shoot()
    self.sprite.frame = 1

    self.timers.charge_up:start()

    local arrow = Objects.instance_at("ArcherArrow", self.x, self.y)
    arrow.dir_x, arrow.dir_y = Vector.direction_between(self.x, self.y, self.player.x, self.player.y)
end

function bow:on_create()
    self.sprite.offset_x = -5
    self.sprite.offset_y = math.floor(self.sprite.texture:getHeight() / 2)
    self.sprite.center = false

    self:create_timer("charge_up", fire, 0.5)
    self:create_timer("cooldown", nil, 0.7)

    self.player = Objects.grab("Player")
end

function bow:on_update(dt)
    self.sprite.rotation = Vector.angle_between(self.x, self.y, self.player.x, self.player.y)
    self.sprite.scale_y = self.x > self.player.x and -1 or 1

    self.x = self.target.x
    self.y = self.target.y - self.target.sprite.texture:getHeight() / 2

    self.depth = self.target.depth + 1
end

function bow:on_draw()
    self.sprite:draw(self.x, self.y)
end

Objects.create_type("ArcherBow", bow)