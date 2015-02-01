#define FUSE_USE_VERSION 26

#include <iostream>
#include <sstream>
#include <stdlib.h>
#include <fuse.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include "board.h"
using std::string;

Move parse_move(string fourcc)
{
    if (fourcc == "----")
	return PASS;
    int x, y, d;
    char c;
    if (fourcc.length() == 4 &&
	sscanf(fourcc.c_str(), "%1X%1X%c%1d", &x, &y, &c, &d) == 4 &&
	x >= 1 && x <= 14 && y >= 1 && y <= 14 &&
	tolower(c) >= 'a' && tolower(c) <= 'u' &&
	d >= 0 && d <= 7)
	return Move(fourcc.c_str());
    else
	return INVALID_MOVE;
}

bool parse_path(const char* path, Board* b, string* name)
{
    if (path[0] != '/')
	return false;

    if (path[1] == '\0') {
	name->clear();
	return true;
    }

    std::istringstream ss(path + 1);
    string s;

    while (std::getline(ss, s, '/') && !ss.eof()) {
	Move m = parse_move(s);
	if (m == INVALID_MOVE || !b->is_valid_move(m))
	    return false;
	b->do_move(m);
    }
    *name = s;
    return true;
}

string score(const Board& b)
{
    char buf[64];
    sprintf(buf, "%d\n%d\n", b.violet_score(), b.orange_score());
    return string(buf);
}

string value(const Board& b)
{
    char buf[64];
    sprintf(buf, "%d\n", b.nega_eval());
    return string(buf);
}

int blokus_getattr(const char *path, struct stat *stbuf)
{
    memset(stbuf, 0, sizeof(struct stat));

    Board b;
    string name;
    if (!parse_path(path, &b, &name))
	return -ENOENT;

    if (name.empty()) {
	stbuf->st_mode = S_IFDIR | 0755;
	stbuf->st_nlink = 2;
	return 0;
    } else if (name == "board") {
	stbuf->st_mode = S_IFREG | 0444;
	stbuf->st_nlink = 1;
	stbuf->st_size = 14 * 15;
	return 0;
    } else if (name == "piece") {
	stbuf->st_mode = S_IFREG | 0444;
	stbuf->st_nlink = 1;
	stbuf->st_size = b.pieces().length();
	return 0;
    } else if (name == "score") {
	stbuf->st_mode = S_IFREG | 0444;
	stbuf->st_nlink = 1;
	stbuf->st_size = score(b).length();
	return 0;
    } else if (name == "value") {
	stbuf->st_mode = S_IFREG | 0444;
	stbuf->st_nlink = 1;
	stbuf->st_size = value(b).length();
	return 0;
    } else {
	Move m = parse_move(name);
	if (m != INVALID_MOVE && b.is_valid_move(m)) {
	    stbuf->st_mode = S_IFDIR | 0755;
	    stbuf->st_nlink = 2;
	    return 0;
	}
    }
    return -ENOENT;
}

int blokus_readdir(const char *path,
		   void *buf,
		   fuse_fill_dir_t filler,
		   off_t offset,
		   struct fuse_file_info *fi)
{
    Board b;
    string name;
    if (!parse_path(path, &b, &name))
	return -ENOENT;

    if (!name.empty()) {
	Move m = parse_move(name);
	if (m == INVALID_MOVE || !b.is_valid_move(m))
	    return -ENOENT;
	b.do_move(m);
    }

    filler(buf, ".",  NULL, 0);
    filler(buf, "..", NULL, 0);
    filler(buf, "board", NULL, 0);
    filler(buf, "piece", NULL, 0);
    filler(buf, "score", NULL, 0);
    filler(buf, "value", NULL, 0);

    Move movables[1500];
    int nmove = b.movables(movables);
    if (nmove == 1 && movables[0] == PASS) {
	b.do_pass();
	int n = b.movables(movables);
	if (n == 1 && movables[0] == PASS)
	    return 0; // End of the game
	movables[0] = PASS;
    }

    for (int i = 0; i < nmove; i++)
	filler(buf, movables[i].fourcc().c_str(), NULL, 0);

    return 0;
}

int blokus_read(const char *path,
		char *buf,
		size_t size,
		off_t offset,
		struct fuse_file_info *fi)
{
    Board b;
    string name;
    if (!parse_path(path, &b, &name))
	return -ENOENT;

    string content;
    if (name == "board")
	content = b.to_str();
    else if (name == "piece")
	content = b.pieces();
    else if (name == "score")
	content = score(b);
    else if (name == "value")
	content = value(b);
    else
	return -ENOENT;

    size_t len = content.length();

    if (static_cast<size_t>(offset) < len) {
	if ((offset + size) > len)
	    size = len - offset;

	memcpy(buf, content.c_str() + offset, size);
    } else {
	size = 0;
    }

    return size;
}

static struct fuse_operations blokus_oper;

int main(int argc, char *argv[])
{
    blokus_oper.getattr = blokus_getattr;
    blokus_oper.readdir = blokus_readdir;
    blokus_oper.read    = blokus_read;
    return fuse_main(argc, argv, &blokus_oper, NULL);
}
