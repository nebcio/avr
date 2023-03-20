#include <zephyr/kernel.h>
#include <zephyr/drivers/gpio.h>

static const struct gpio_dt_spec orange_led = GPIO_DT_SPEC_GET(DT_NODELABEL(orange_led_3), gpios);
static const struct gpio_dt_spec green_led = GPIO_DT_SPEC_GET(DT_NODELABEL(green_led_4), gpios);
static const struct gpio_dt_spec red_led = GPIO_DT_SPEC_GET(DT_NODELABEL(red_led_5), gpios);
static const struct gpio_dt_spec blue_led = GPIO_DT_SPEC_GET(DT_NODELABEL(blue_led_6), gpios);

static const struct gpio_dt_spec button = GPIO_DT_SPEC_GET(DT_NODELABEL(user_button), gpios);
static struct gpio_callback button_cb_data;
static struct k_timer led_timer;
static struct k_timer button_timer;
static int program = 0;
static int leds_state = 8;


static void gpio_diode_config() {
    gpio_pin_configure_dt(&red_led, GPIO_OUTPUT_INACTIVE);
    gpio_pin_configure_dt(&orange_led, GPIO_OUTPUT_INACTIVE);
    gpio_pin_configure_dt(&green_led, GPIO_OUTPUT_INACTIVE);
    gpio_pin_configure_dt(&blue_led, GPIO_OUTPUT_INACTIVE);
}

void set_states_of_leds() {
    gpio_pin_set_dt(&red_led, leds_state & 8);
    gpio_pin_set_dt(&orange_led, leds_state & 4);
    gpio_pin_set_dt(&green_led, leds_state & 2);
    gpio_pin_set_dt(&blue_led, leds_state & 1);
}

void shift_leds() {
    // if bit 1 is 1, add 16
    if (leds_state & 1){
        leds_state += 16;
        leds_state -= 1;
    }
    leds_state = leds_state >> 1;
}

static void led_timer_handler(struct k_timer *timer) {
    // shift bits
    shift_leds();
    set_states_of_leds();
}

static void button_timer_handler(struct k_timer *timer) {
    // switch program
    program = program < 3 ? program + 1 : 0;
    if (program == 1)
        leds_state = 12;
    else if (program == 2)
        leds_state = 14;
    else
        leds_state = 8;
}

static void button_pressed(const struct device *dev, struct gpio_callback *cb, uint32_t pins) {
    k_timer_start(&button_timer, K_MSEC(100), K_NO_WAIT);
}

void main(void) {

    gpio_diode_config();
    gpio_pin_configure_dt(&button, GPIO_INPUT);

    gpio_pin_interrupt_configure_dt(&button, GPIO_INT_EDGE_TO_ACTIVE);
    gpio_init_callback(&button_cb_data, button_pressed, BIT(button.pin));
    gpio_add_callback(button.port, &button_cb_data);

    k_timer_init(&led_timer, led_timer_handler, NULL);
    k_timer_init(&button_timer, button_timer_handler, NULL);

    k_timer_start(&led_timer, K_SECONDS(1), K_SECONDS(1));
}