const std = @import("std");
const httpz = @import("httpz");
const serial = @import("serial");

const serialPath = "/dev/ttyS0";

pub fn main() !u8 {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const allocator = gpa.allocator();

    var serialFd = std.fs.openFileAbsolute(serialPath, .{ .mode = .read_write }) catch |err| switch (err) {
        error.FileNotFound => {
            try std.io.getStdErr().writer().print("The serial port {s} does not exist.\n", .{serialPath});
            return 1;
        },
        else => return err,
    };
    defer serialFd.close();

    try serial.configureSerialPort(serialFd, .{ .baud_rate = 9600, .word_size = .eight, .parity = .none, .stop_bits = .one });

    try serialFd.writeAll("FAN\r");

    var buffer: [7]u8 = undefined;
    _ = try serialFd.readAll(&buffer);

    try std.io.getStdOut().writeAll(&buffer);

    //     var server = try httpz.Server().init(allocator, .{ .port = 5882 });

    //     server.notFound(notFound);
    //     server.errorHandler(errorHandler);

    //     var router = server.router();

    //     router.get("/metrics", getMetrics);

    //     try server.listen();
    return 0;
}

// fn getMetrics(req: *httpz.Request, res: *httpz.Response) !void {}

// fn notFound(_: *httpz.Request, res: *httpz.Response) !void {
//     res.status = 404;
//     res.body = "Not Found";
// }

// // note that the error handler return `void` and not `!void`
// fn errorHandler(req: *httpz.Request, res: *httpz.Response, err: anyerror) void {
//     res.status = 500;
//     res.body = "Internal Server Error";
//     std.log.err("httpz: unhandled exception for request: {s}\nErr: {}", .{ req.url.raw, err });
// }
