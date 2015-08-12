# Enables control over a set of DualTone objects via mouse and/or touch interactions
class AudioSpace
  constructor: (@el, @min_frequency = 500, @max_frequency = 1500) ->
    AudioContext = window.AudioContext || window.webkitAudioContext
    @audio_context = new AudioContext()
    @visuals = new PhoneoPhone.RenderedWaves {
      el: @el,
      wavesWidth: '100%',
      ease: 'linear',
    }
    @dual_tones = {}
    @add_mouse_control()
    @add_touch_control()

  add_dual_tone: (dual_tone_id, position) =>
    frequency =  @_frequency_at_y(position.y)
    crossfade =  @_crossfade_at_x(position.x)
    @dual_tones[dual_tone_id] = new PhoneoPhone.DualTone(@audio_context, frequency, crossfade)
    @add_dual_tone_visuals(dual_tone_id, position.y)

  add_dual_tone_visuals: (dual_tone_id, yAxis) =>
    _.each  @dual_tones[dual_tone_id].tones, (tone, tone_key) ->
      wave_id = "#{dual_tone_id}_#{tone_key}"
      @visuals.add_wave(wave_id, tone.frequency, tone.gain_value, tone.type, yAxis, @min_frequency, @max_frequency)
    , @

  update_dual_tone: (dual_tone_id, position) =>
    if _.isObject(@dual_tones[dual_tone_id])
      frequency =  @_frequency_at_y(position.y)
      crossfade =  @_crossfade_at_x(position.x)
      @dual_tones[dual_tone_id].update(frequency, crossfade)
      @update_dual_tone_visuals(dual_tone_id, position.y)

  update_dual_tone_visuals: (dual_tone_id, yAxis) =>
    _.each  @dual_tones[dual_tone_id].tones, (tone, tone_key) ->
      wave_id = "#{dual_tone_id}_#{tone_key}"
      @visuals.update_wave(wave_id, tone.frequency, tone.gain_value, yAxis, @min_frequency, @max_frequency)
    , @

  delete_dual_tone: (dual_tone_id) =>
    if @dual_tones[dual_tone_id]
      @delete_dual_tone_visuals(dual_tone_id)
      delete @dual_tones[dual_tone_id]

  delete_dual_tone_visuals: (dual_tone_id) =>
    _.each  @dual_tones[dual_tone_id].tones, (tone, tone_key) ->
      wave_id = "#{dual_tone_id}_#{tone_key}"
      @visuals.delete_wave(wave_id)
    , @

  add_mouse_control: (dual_tone_id, start_event, change_event, stop_event) =>
    self = @
    dual_tone_id = 'mouse'
    @el.addEventListener 'mousedown', (event) ->
      event.preventDefault()
      self.on_start_event(event, dual_tone_id)
    @el.addEventListener 'mousemove', (event) ->
      event.preventDefault()
      self.on_change_event(event, dual_tone_id)
    @el.addEventListener 'mouseup', (event) ->
      event.preventDefault()
      self.on_stop_event(event, dual_tone_id)

  add_touch_control: () =>
    self = @
    @el.addEventListener 'touchstart', (event) ->
      event.preventDefault()
      _.each event.changedTouches, (touch) ->
        self.on_start_event(touch, touch.identifier)

    @el.addEventListener 'touchmove', (event) ->
      event.preventDefault()
      _.each event.changedTouches, (touch) ->
        self.on_change_event(touch, touch.identifier)

    @el.addEventListener 'touchend', (event) ->
      event.preventDefault()
      _.each event.changedTouches, (touch) ->
        self.on_stop_event(touch, touch.identifier)

  on_start_event: (event, dual_tone_id) =>
    @add_dual_tone(dual_tone_id, {x: event.clientX, y: event.clientY})
    @start_tone(dual_tone_id)

  on_change_event: (event, dual_tone_id) =>
    @update_dual_tone(dual_tone_id, {x: event.clientX, y: event.clientY})

  on_stop_event: (event, dual_tone_id) =>
    @stop_tone(dual_tone_id)
    @delete_dual_tone(dual_tone_id)

  start_tone: (dual_tone_id) =>
    if _.isObject(@dual_tones[dual_tone_id])
      @dual_tones[dual_tone_id].start()

  stop_tone: (dual_tone_id) =>
    if _.isObject(@dual_tones[dual_tone_id])
      @dual_tones[dual_tone_id].stop()

  # Private methods
  _frequency_at_y: (y) =>
    ((y / window.innerHeight) * (@max_frequency - @min_frequency)) + @min_frequency

  _crossfade_at_x: (x) =>
    x / window.innerWidth

window.PhoneoPhone = window.PhoneoPhone || {}
PhoneoPhone.AudioSpace = AudioSpace
