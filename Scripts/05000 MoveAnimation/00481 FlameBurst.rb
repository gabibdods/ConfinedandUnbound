ya = Yuki::Animation
animation_user = Yuki::Animation::UserBankRelativeAnimation.new
# FlameBurst
animation_target = ya.wait(0.1)
animation_user.play_on_bank(0, ya.create_sprite(:viewport, :sprite, Sprite, nil, [:load, 'FlameBurst_0', :animation], [:set_rect, 0, 0, 104, 90], [:zoom=, 1.35], [:set_origin, -20, 90]))
animation_user.play_on_bank(1, ya.create_sprite(:viewport, :sprite, Sprite, nil, [:load, 'FlameBurst_1', :animation], [:set_rect, 0, 0, 104, 90], [:zoom=, 1.35], [:set_origin, 120, 40]))
main_t_anim = ya.resolved
animation_user.play_before(main_t_anim)
main_t_anim.play_before(ya.move_sprite_position(0, :sprite, :user, :user))
main_t_anim.play_before(ya.se_play('moves/FlameBurst'))
main_t_anim.play_before(ya.wait(0.1))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 0, 0, 104, 90))
main_t_anim.play_before(ya.wait(0.12))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 104, 0, 104, 90))
main_t_anim.play_before(ya.wait(0.12))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 208, 0, 104, 90))
main_t_anim.play_before(ya.wait(0.12))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 312, 0, 104, 90))
main_t_anim.play_before(ya.wait(0.12))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 416, 0, 104, 90))
main_t_anim.play_before(ya.wait(0.12))
main_t_anim.play_before(ya.send_command_to(:sprite, :set_rect, 520, 0, 104, 90))
main_t_anim.play_before(ya.wait(0.12))
animation_user.play_before(ya.dispose_sprite(:sprite))

Battle::MoveAnimation.register_specific_animation(:flame_burst, :first_use, animation_user, animation_target)
