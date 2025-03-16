local name, path
local size = {}

function interp(s, tab)
	return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
  end

:: beginning ::
print("egui Boilerplate Generator v1.0.0")
print("---------------------------------")

-- name
io.write("Enter your app's name (window title): ")
name = io.read()

-- size
io.write("\nEnter your app's window width: ")
size.width = io.read()

io.write("Enter your app's height: ")
size.height = io.read()

-- filepath
io.write("\nEnter the path to the directory where you want the output file (main.rs) to be located: ")
path = io.read()

-- confirmation
io.write(
	interp("\nYour current configuration:\n\tApp name: \"${app_name}\"\n\tApp window size: ${width}, ${height}\n\tOutput file path: \"${out_path}\"", {
		app_name = name,
		width = size.width,
		height = size.height,
		out_path = path
	}
))
io.write("\nIs this correct (y/n)?")
local input = io.read()

if(input ~= "y") then
	io.write("\027[H\027[2J")
	goto beginning
end

-- create the output string
local out = interp([[
use eframe::egui;

fn main() -> eframe::Result {
	let options = eframe::NativeOptions {
		viewport: egui::ViewportBuilder::default().with_inner_size([${width}.0, ${height}.0]),
		..Default::default()
	};

	eframe::run_native(
		"${app_name}",
		options,
		Box::new(|cc| { Ok(Box::<App>::default())}),
	)
}

struct App {}

impl Default for App {
	fn default() -> Self {
		Self {}
	}
}

impl eframe::App for App {
	fn update(&mut self, ctx : &egui::Context, _frame : &mut eframe::Frame) {
		egui::CentralPanel::default().show(ctx, |ui| {});
	}
}
]], {
	width = size.width,
	height = size.height,
	app_name = name
})

-- write to the file
local file = assert(io.open(path.."/main.rs", "w"))
file:write(out)
file:close()

print("\nOutput written to "..path.."/main.rs\n")
os.exit()