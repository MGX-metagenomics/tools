
#include <iostream>
#include <fstream>
#include <vector>
#include <unordered_map>
#include <getopt.h>

using namespace std;

std::vector<string> split(string str, char sep) {
    std::vector<string> strings;
    int startIndex = 0, endIndex = 0;
    for (size_t i = 0; i <= str.size(); i++) {
        
        if (str[i] == sep || i == str.size()) {
            endIndex = i;
            string temp;
            temp.append(str, startIndex, endIndex - startIndex);
            strings.push_back(temp);
            startIndex = endIndex + 1;
        }
    }
    return strings;
}

inline int fast_atoi(const char *p) {
    int x = 0;
    while (*p != '\0') {
        x = (x*10) + (*p - '0');
        ++p;
    }
    return x;
}

inline int fast_stoi(const string &s) {
    return fast_atoi(s.c_str());
}


void addFile(unordered_map<string, int> &data, const string &fname) {
    ifstream infile(fname);
    if (!infile.good()) {
        cerr << "Unable to read file " << fname << endl;
        exit(1);
    }
    string line;
    const string delim = "\t";
    while (std::getline(infile, line)) {
        if (line.starts_with("#") || line.starts_with("Geneid")) {
            continue;
        }
        std::vector<string> v = split(line, '\t');
        const string name = v[0];
        const int count = fast_stoi(v[6]);
        if (data.contains(name)) {
            data[name] = data[name] + count;
        } else {
            data[name] = count;
        }
    }
}

int main(int argc, char *argv[]) {

    string outfile;
    string infiles;

    int c;
    while ((c = getopt(argc, argv, "i:o:")) != -1) {
        switch (c) {
            case 'o': 
                outfile.assign(optarg);
                break;
            case 'i': 
                infiles.assign(optarg);
                break;
            default:
                cerr << "Usage: mergeFC -i file1,file2,file3 -o outfile" << endl;
                return -1;
        }
    }

    vector<string> files = split(infiles, ',');

    unordered_map<string, int> data;

    for (auto f : files) {
       addFile(data, f);
    }

    ofstream o(outfile);
    for (const auto& [key, value] : data) {
        o << key << "\t" << value << endl;
    }
    o.close();

    return 0;
}

