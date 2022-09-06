// g++ c_examples/cairo_test.cpp -o bin/cairo_test -I/usr/include/cairo -I/usr/include/glib-2.0 -I/usr/lib/x86_64-linux-gnu/glib-2.0/include -I/usr/include/pixman-1 -I/usr/include/uuid -I/usr/include/freetype2 -I/usr/include/libpng16 -lX11 -lcairo
#include <cairo.h>
#include <cairo-xlib.h>
#include <string>
#include <cstdio>

using namespace std;

int main (int argc, char *argv[])
{
	cairo_surface_t *surface;
	cairo_t *cr;

	surface = cairo_image_surface_create (CAIRO_FORMAT_ARGB32, 800, 600);
	cr = cairo_create (surface);
	/* Examples are in 1.0 x 1.0 coordinate space */
	cairo_scale (cr, 800, 600);

	/* Drawing code goes here */
	cairo_set_source_rgb (cr, 1.0, 0, 0);
	cairo_rectangle (cr, 0, 0, 1.0, 1.0);
	cairo_fill(cr);

	Display *display = XOpenDisplay(NULL);
	int default_scr = DefaultScreen(display);
	Visual *visual = DefaultVisual(display, default_scr);
	Window root_win = RootWindow(display, default_scr);
	Drawable drawable = XCreateSimpleWindow(display, root_win, 0, 0, 800, 600, 0,
			BlackPixel(display, default_scr), WhitePixel(display, default_scr));

	XSelectInput(display, drawable, ExposureMask);
	XMapWindow(display, drawable);
	XFlush(display);
	XSync(display, default_scr);


	int height;
	int width;
	XEvent event;
	while (1)
	{
		while(XPending(display) > 0)
		{
			XNextEvent(display, &event);
			switch (event.type)
			{
			case Expose:
			{
				width = event.xexpose.width;
				height = event.xexpose.height;
				cairo_surface_t *x11_sf = cairo_xlib_surface_create(display, drawable, visual, width, height);
				cairo_t *x11_cr = cairo_create(x11_sf);
				cairo_scale(x11_cr, double(width) / 800, double(height) / 600);
				cairo_set_source_surface(x11_cr, surface, 0, 0);
				cairo_paint(x11_cr);
				cairo_destroy(x11_cr);
				cairo_surface_destroy(x11_sf);
			}
				break;
			}
		}

	}


	/* Write output and clean up */
	cairo_destroy (cr);
	cairo_surface_destroy (surface);

	return 0;
}