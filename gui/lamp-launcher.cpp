#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/fb.h>
#include <sys/mman.h>

#define WIDTH 1024
#define HEIGHT 768
#define BPP 4

typedef struct {
    unsigned char b, g, r, a;
} Pixel;

struct fb_var_screeninfo vinfo;
struct fb_fix_screeninfo finfo;
Pixel *fb_mem;
int fb_fd;

void init_framebuffer() {
    fb_fd = open("/dev/fb0", O_RDWR);
    if (fb_fd < 0) {
        printf("Framebuffer not available, using fallback GUI\n");
        return;
    }
    
    ioctl(fb_fd, FBIOGET_FSCREENINFO, &finfo);
    ioctl(fb_fd, FBIOGET_VSCREENINFO, &vinfo);
    
    size_t fb_size = vinfo.yres_virtual * finfo.line_length;
    fb_mem = (Pixel*)mmap(0, fb_size, PROT_READ | PROT_WRITE, MAP_SHARED, fb_fd, 0);
}

void draw_pixel(int x, int y, unsigned char r, unsigned char g, unsigned char b) {
    if (x >= 0 && x < WIDTH && y >= 0 && y < HEIGHT && fb_mem) {
        Pixel *p = &fb_mem[y * WIDTH + x];
        p->r = r; p->g = g; p->b = b; p->a = 255;
    }
}

void draw_rectangle(int x, int y, int w, int h, unsigned char r, unsigned char g, unsigned char b) {
    for (int yy = y; yy < y + h; yy++) {
        for (int xx = x; xx < x + w; xx++) {
            draw_pixel(xx, yy, r, g, b);
        }
    }
}

void draw_button(int x, int y, int w, int h, const char *text, int hovered) {
    // زر Windows 7 الأزرق
    unsigned char r = hovered ? 100 : 70;
    unsigned char g = hovered ? 150 : 120;
    unsigned char b = hovered ? 200 : 180;
    
    draw_rectangle(x, y, w, h, r, g, b);
    
    // Border
    for (int i = 0; i < w; i++) {
        draw_pixel(x + i, y, 255, 255, 255);
        draw_pixel(x + i, y + h - 1, 80, 80, 80);
    }
    for (int i = 0; i < h; i++) {
        draw_pixel(x, y + i, 255, 255, 255);
        draw_pixel(x + w - 1, y + i, 80, 80, 80);
    }
}

void draw_taskbar() {
    // شريط مهام Windows 7
    draw_rectangle(0, HEIGHT - 50, WIDTH, 50, 200, 200, 200);
    
    // Border علوي
    for (int x = 0; x < WIDTH; x++) {
        draw_pixel(x, HEIGHT - 50, 100, 100, 100);
    }
    
    // بدء في الزاوية اليسرى
    draw_rectangle(5, HEIGHT - 45, 50, 40, 70, 120, 180);
}

void draw_wallpaper() {
    // خلفية زرقاء مثل Windows 7
    draw_rectangle(0, 0, WIDTH, HEIGHT - 50, 100, 150, 200);
    
    // gradient effect (تدرج)
    for (int y = 0; y < HEIGHT - 50; y++) {
        unsigned char intensity = (unsigned char)(100 + (y * 100) / (HEIGHT - 50));
        draw_rectangle(0, y, WIDTH, 1, intensity / 2, intensity, intensity + 55);
    }
}

void draw_window(int x, int y, int w, int h, const char *title) {
    // نافذة مثل Windows 7
    draw_rectangle(x, y, w, h, 230, 230, 230);
    
    // Title bar زرقاء
    draw_rectangle(x, y, w, 25, 50, 120, 215);
    
    // Title text (mock - بدون rendering نصوص كامل)
    // هنا يمكن إضافة rendering نصوص إذا لزم
    
    // Border
    for (int i = 0; i < w; i++) {
        draw_pixel(x + i, y, 255, 255, 255);
        draw_pixel(x + i, y + h - 1, 100, 100, 100);
    }
    for (int i = 0; i < h; i++) {
        draw_pixel(x, y + i, 255, 255, 255);
        draw_pixel(x + w - 1, y + i, 100, 100, 100);
    }
}

void draw_start_menu() {
    int menu_width = 250;
    int menu_height = 400;
    int x = 5;
    int y = HEIGHT - 50 - menu_height - 5;
    
    draw_rectangle(x, y, menu_width, menu_height, 240, 240, 240);
    
    // Header أزرق
    draw_rectangle(x, y, menu_width, 40, 50, 120, 215);
    
    // Items
    int item_y = y + 50;
    int item_height = 35;
    
    // menu items
    const char *items[] = {
        "File Manager",
        "Text Editor",
        "Terminal",
        "Settings",
        "Shutdown"
    };
    
    for (int i = 0; i < 5; i++) {
        draw_rectangle(x + 5, item_y + i * item_height, menu_width - 10, item_height - 5, 230, 230, 230);
    }
}

int main() {
    printf("LAMP OS - Graphical Launcher v1.0\n");
    printf("Initializing framebuffer...\n");
    
    init_framebuffer();
    
    if (!fb_mem) {
        printf("Using fallback GUI mode\n");
        printf("\n╔════════════════════════════════════╗\n");
        printf("║    LAMP OS - Graphical Desktop    ║\n");
        printf("║  Windows 7-Like Interface v1.0    ║\n");
        printf("╚════════════════════════════════════╝\n\n");
        
        printf("Available Applications:\n");
        printf("  1. File Manager\n");
        printf("  2. Text Editor\n");
        printf("  3. Terminal\n");
        printf("  4. Settings\n");
        printf("  5. Shutdown\n\n");
        
        printf("Select an application (1-5): ");
        fflush(stdout);
        
        char choice;
        if (scanf("%c", &choice) == 1) {
            switch(choice) {
                case '1':
                    system("lamp-menu");
                    break;
                case '2':
                    system("vi /tmp/note.txt");
                    break;
                case '3':
                    system("/bin/sh");
                    break;
                case '4':
                    system("lamp-system");
                    break;
                case '5':
                    system("poweroff");
                    break;
            }
        }
    } else {
        printf("Drawing Windows 7-like interface...\n");
        
        draw_wallpaper();
        draw_taskbar();
        draw_start_menu();
        
        // Draw some windows
        draw_window(100, 100, 600, 400, "File Manager");
        draw_button(300, 450, 150, 40, "Open", 0);
        
        printf("GUI Rendered - Press any key to continue\n");
        getchar();
        
        munmap(fb_mem, vinfo.yres_virtual * finfo.line_length);
    }
    
    close(fb_fd);
    return 0;
}
