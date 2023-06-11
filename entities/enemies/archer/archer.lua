local substance = require "substance"
local voiceline = require "entities.voicelineplayer"
local collision = require "entities.collide"

local hurt_sounds = {
    love.audio.newSource("entities/enemies/hurt1.mp3", "stream"),
    love.audio.newSource("entities/enemies/hurt2.mp3", "stream"),
    love.audio.newSource("entities/enemies/hurt3.mp3", "stream"),
}

local death = love.audio.newSource("entities/enemies/nooo.mp3", "stream")
local substance_death = love.audio.newSource("entities/enemies/nomysubstance.mp3", "stream")

local function flee(self, dt)
    self.sprite:apply_animation(self.walk_animation)

    local dir_x, dir_y = Vector.direction_between(self.x, self.y, self.target.x, self.target.y)

    self.vel_x = math.lerp(self.vel_x, -dir_x * self.flee_speed, self.accel * dt)
    self.vel_y = math.lerp(self.vel_y, -dir_y * self.flee_speed, self.accel * dt)

    self.sprite.scale_x = self.target.x < self.x and -1 or 1

    collision.move(self, "Solids", self.vel_x * dt, self.vel_y * dt)
end

local function attack(self, dt)
    self.sprite:apply_animation(self.attack_animation)

    self.vel_x = math.lerp(self.vel_x, 0, self.frict * dt)
    self.vel_y = math.lerp(self.vel_y, 0, self.frict * dt)

    collision.move(self, "Solids", self.vel_x * dt, self.vel_y * dt)
end

local function charge(self, dt)
    self.sprite:apply_animation(self.walk_animation)

    local dir_x, dir_y = Vector.direction_between(self.x, self.y, self.target.x, self.target.y)--Room.get_path("Solids", self.x, self.y, self.player.x, self.player.y)

    self.vel_x = math.lerp(self.vel_x, dir_x * self.speed, self.accel * dt)
    self.vel_y = math.lerp(self.vel_y, dir_y * self.speed, self.accel * dt)

    self.sprite.scale_x = self.target.x < self.x and -1 or 1

    collision.move(self, "Solids", self.vel_x * dt, self.vel_y * dt)

    local dist_to_player = Vector.distance_between(self.x, self.y, self.player.x, self.player.y)
    if dist_to_player < 80 then
        self.state = attack
        self.timers.attack:start()
    end
end

local function default(self, dt)
    local dist_to_player = Vector.distance_between(self.x, self.y, self.player.x, self.player.y)
    if dist_to_player < 190 then
        self.state = charge
    end
end


Objects.create_type_from("Archer", "Enemy", {
    sprite = Sprite.new("entities/enemies/archer/archer.png", 7, 10),
    corpse_sprite = Sprite.new("entities/enemies/archer/archercorpse.png", 1, 0),
    idle_animation = Sprite.new_animation(1, 3, 10),
    walk_animation = Sprite.new_animation(4, 6, 10),
    attack_animation = Sprite.new_animation(7, 7, 0),

    speed = 90,
    flee_speed = 180,
    accel = 3,
    frict = 6,

    health = 15,

    state = default,

    on_attack_over = function(self)
        if self.state == default then
            return
        end
        self.bow:shoot()
        self.state = flee
        self.timers.flee:start()
    end,
    on_flee_over = function(self)
        if self.state == default then
            return
        end
        self.state = charge
    end,

    on_create = function(self)
        self.sprite:apply_animation(self.idle_animation)
        self.sprite.offset_y = math.floor(self.sprite.texture:getHeight() / 2)

        self:create_timer("attack", self.on_attack_over, 0.5)
        self:create_timer("flee", self.on_flee_over, 0.75)

        self:call_from_base("on_create")

        self.bow = Objects.instance_at("ArcherBow", self.x, self.y)
        self.bow.target = self
    end,
    on_update = function(self, dt)
        self:call_from_base("on_update", dt)
        self:state(dt)
    end,

    on_death = function(self)
        Objects.destroy(self.bow)
        
        if love.math.random() < 0.2 then
            local death_sfx = substance.unlocked and substance_death or death
            local subtitle = substance.unlocked and "NOOO! MY SUBSTANCE!" or "NOOO!"
            voiceline.play_line(death_sfx, 0, "Archer", subtitle)
        end
    end,

    on_hurt = function(self)
        if love.math.random() < 0.5 then
            hurt_sounds[love.math.random(1, #hurt_sounds)]:play()
        end
    end
})