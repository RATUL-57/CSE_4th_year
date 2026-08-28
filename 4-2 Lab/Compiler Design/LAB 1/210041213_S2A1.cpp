#include <bits/stdc++.h>

using namespace std;

static string joinTokens(const vector<string>& items) {
	if (items.empty()) return "[]";
	string out = "[";
	for (size_t i = 0; i < items.size(); i++) {
		out += items[i];
		if (i + 1 < items.size()) out += ", ";
	}
	out += "]";
	return out;
}

static string escapeForQuoted(const string& s) {
	string out;
	out.reserve(s.size());
	for (char c : s) {
		if (c == '\\' || c == '"') out.push_back('\\');
		out.push_back(c);
	}
	return out;
}

static string joinQuotedCSV(const vector<string>& items) {
	string out;
	for (size_t i = 0; i < items.size(); i++) {
		out += "\"" + escapeForQuoted(items[i]) + "\"";
		if (i + 1 < items.size()) out += ", ";
	}
	return out;
}

static bool isIdentifierStart(char c) {
	return std::isalpha(static_cast<unsigned char>(c)) || c == '_';
}

static bool isIdentifierChar(char c) {
	return std::isalnum(static_cast<unsigned char>(c)) || c == '_';
}

static bool isPunct(char c) {
	return std::ispunct(static_cast<unsigned char>(c)) != 0;
}

static bool isStopChar(char c) {
	return std::isspace(static_cast<unsigned char>(c)) || c == '\0';
}

static string ltrim(const string& s) {
	size_t i = 0;
	while (i < s.size() && std::isspace(static_cast<unsigned char>(s[i]))) i++;
	return s.substr(i);
}

int main(int argc, char** argv) {
	const string inputPath = (argc >= 2) ? argv[1] : "Sample_input.txt";
	ifstream in(inputPath);
	if (!in) {
		cerr << "Failed to open input file: " << inputPath << "\n";
		cerr << "Run as: " << (argc > 0 ? argv[0] : "lexer") << " <input_file>\n";
		return 1;
	}

	const unordered_set<string> keywords = {
		"int", "float", "double", "char", "bool", "void",
		"if", "else", "for", "while", "do",
		"switch", "case", "break", "continue", "return",
		"class", "struct", "public", "private", "using", "namespace", "nullptr"
	};

	const unordered_set<string> opIncDec = {"++", "--"};
	const unordered_set<string> opAssignment = {
		"=", "+=", "-=", "*=", "/=", "%="
	};
	const unordered_set<string> opArithmetic = {"+", "-", "*", "/", "%"};
	const unordered_set<string> opRelational = {"==", "!=", "<", ">", "<=", ">="};
	const unordered_set<string> opLogical = {"&&", "||", "!"};
	const unordered_set<string> opBitwise = {"&", "|", "^", "~", "<<", ">>"};

	const unordered_set<string> delimiters = {
		";", ",", "(", ")", "{", "}", "[", "]", ".", ":", "#"
	};

	const vector<string> multiOps = {
		"++", "--",
		"+=", "-=", "*=", "/=", "%=",
		"==", "!=", "<=", ">=",
		"&&", "||",
		"<<", ">>"
	};

	size_t totalKeywords = 0;
	size_t totalIdentifiers = 0;
	size_t totalIntConsts = 0;
	size_t totalFloatConsts = 0;
	size_t totalStringConsts = 0;
	size_t totalCharConsts = 0;
	size_t totalOpArithmetic = 0;
	size_t totalOpRelational = 0;
	size_t totalOpLogical = 0;
	size_t totalOpBitwise = 0;
	size_t totalOpAssignment = 0;
	size_t totalOpIncDec = 0;
	size_t totalDelimiters = 0;

	unordered_set<string> uniqueKeywordSet;
	unordered_set<string> uniqueIdentifierSet;
	unordered_map<string, size_t> identifierFreq;
	unordered_map<string, size_t> identifierFirstLine;
	vector<string> allErrors;
	vector<string> commentBlocks;
	bool inBlockComment = false;
	string currentComment;

	string line;
	size_t lineNo = 0;
	while (std::getline(in, line)) {
		lineNo++;
		string trimmed = ltrim(line);

		if (inBlockComment) {
			currentComment += "\n" + line;
			if (trimmed.find("*/") != string::npos || line.find("*/") != string::npos) {
				commentBlocks.push_back(currentComment);
				currentComment.clear();
				inBlockComment = false;
			}
			continue;
		}

		if (trimmed.rfind("//", 0) == 0) {
			commentBlocks.push_back(line);
			continue;
		}
		if (trimmed.rfind("/*", 0) == 0) {
			currentComment = line;
			if (line.find("*/") != string::npos) {
				commentBlocks.push_back(currentComment);
				currentComment.clear();
			} else {
				inBlockComment = true;
			}
			continue;
		}

		vector<string> lineKeywords;
		vector<string> lineIdentifiers;
		vector<string> tokenStream;
		vector<pair<string, string>> typedStream;
		vector<string> lineErrors;
		bool isPreprocessorLine = (trimmed.rfind("#", 0) == 0);

		vector<string> lineIntConsts;
		vector<string> lineFloatConsts;
		vector<string> lineStringConsts;
		vector<string> lineCharConsts;

		vector<string> lineOpArithmetic;
		vector<string> lineOpRelational;
		vector<string> lineOpLogical;
		vector<string> lineOpBitwise;
		vector<string> lineOpAssignment;
		vector<string> lineOpIncDec;

		vector<string> lineDelimiters;

		auto addOperator = [&](const string& op) {
			tokenStream.push_back(op);
			if (opIncDec.count(op)) {
				lineOpIncDec.push_back(op);
				typedStream.push_back({"INCDEC_OP", op});
			} else if (opAssignment.count(op)) {
				lineOpAssignment.push_back(op);
				typedStream.push_back({"ASSIGNMENT_OP", op});
			} else if (opRelational.count(op)) {
				lineOpRelational.push_back(op);
				typedStream.push_back({"RELATIONAL_OP", op});
			} else if (opLogical.count(op)) {
				lineOpLogical.push_back(op);
				typedStream.push_back({"LOGICAL_OP", op});
			} else if (opBitwise.count(op)) {
				lineOpBitwise.push_back(op);
				typedStream.push_back({"BITWISE_OP", op});
			} else if (opArithmetic.count(op)) {
				lineOpArithmetic.push_back(op);
				typedStream.push_back({"ARITHMETIC_OP", op});
			}
			else {
				// Not in our categorized sets; do nothing.
			}
		};

		auto isBoundaryChar = [&](char ch) -> bool {
			if (std::isspace(static_cast<unsigned char>(ch)) || ch == '\0') return true;
			string s(1, ch);
			return delimiters.count(s) || opArithmetic.count(s) || opRelational.count(s) ||
				opLogical.count(s) || opBitwise.count(s) || opAssignment.count(s);
		};

		auto addError = [&](const string& message, const string& lexeme) {
			string entry = message + ": " + lexeme;
			lineErrors.push_back(entry);
			allErrors.push_back("Line " + to_string(lineNo) + ": " + entry);
		};

		const size_t n = line.size();
		size_t i = 0;
		while (i < n) {
			char c = line[i];

			if (std::isspace(static_cast<unsigned char>(c))) {
				i++;
				continue;
			}

			// Line comment: ignore rest of the line.
			if (i + 1 < n && line[i] == '/' && line[i + 1] == '/') {
				break;
			}

			// String constant
			if (c == '"') {
				size_t start = i;
				i++; // consume opening quote
				bool escaped = false;
				while (i < n) {
					char ch = line[i];
					if (escaped) {
						escaped = false;
						i++;
						continue;
					}
					if (ch == '\\') {
						escaped = true;
						i++;
						continue;
					}
					if (ch == '"') {
						i++; // consume closing quote
						break;
					}
					i++;
				}
				{
					string lex = line.substr(start, i - start);
					lineStringConsts.push_back(lex);
					tokenStream.push_back(lex);
					typedStream.push_back({"STRING_CONST", lex});
				}
				continue;
			}

			// Character constant
			if (c == '\'') {
				size_t start = i;
				i++; // consume opening quote
				bool escaped = false;
				while (i < n) {
					char ch = line[i];
					if (escaped) {
						escaped = false;
						i++;
						continue;
					}
					if (ch == '\\') {
						escaped = true;
						i++;
						continue;
					}
					if (ch == '\'') {
						i++; // consume closing quote
						break;
					}
					i++;
				}
				{
					string lex = line.substr(start, i - start);
					lineCharConsts.push_back(lex);
					tokenStream.push_back(lex);
					typedStream.push_back({"CHAR_CONST", lex});
				}
				continue;
			}

			bool matchedMulti = false;
			for (const string& op : multiOps) {
				if (isPreprocessorLine && (op.find('<') != string::npos || op.find('>') != string::npos)) {
					continue;
				}
				if (i + op.size() <= n && line.compare(i, op.size(), op) == 0) {
					addOperator(op);
					i += op.size();
					matchedMulti = true;
					break;
				}
			}
			if (matchedMulti) continue;

			string one(1, c);
			if (isPreprocessorLine && (c == '<' || c == '>')) {
				lineDelimiters.push_back(one);
				tokenStream.push_back(one);
				typedStream.push_back({"DELIMITER", one});
				i++;
				continue;
			}
			if (delimiters.count(one)) {
				lineDelimiters.push_back(one);
				tokenStream.push_back(one);
				typedStream.push_back({"DELIMITER", one});
				i++;
				continue;
			}
			if (opArithmetic.count(one) || opRelational.count(one) || opLogical.count(one) ||
				opBitwise.count(one) || opAssignment.count(one)) {
				addOperator(one);
				i++;
				continue;
			}

			if (isIdentifierStart(c)) {
				size_t start = i;
				i++;
				while (i < n && isIdentifierChar(line[i])) i++;
				string word = line.substr(start, i - start);
				tokenStream.push_back(word);
				if (keywords.count(word)) {
					lineKeywords.push_back(word);
					typedStream.push_back({"KEYWORD", word});
				} else {
					lineIdentifiers.push_back(word);
					typedStream.push_back({"IDENTIFIER", word});
					identifierFreq[word]++;
					if (!identifierFirstLine.count(word)) identifierFirstLine[word] = lineNo;
				}
				continue;
			}

			if (std::isdigit(static_cast<unsigned char>(c)) || (c == '.' && i + 1 < n && std::isdigit(static_cast<unsigned char>(line[i + 1])))) {
				size_t start = i;
				bool seenDot = (c == '.');
				bool seenExp = false;
				bool expDigits = false;
				bool invalidNumeric = false;
				i++;

				while (i < n) {
					char ch = line[i];
					if (std::isdigit(static_cast<unsigned char>(ch))) {
						if (seenExp) expDigits = true;
						i++;
						continue;
					}
					if (ch == '.' && !seenDot && !seenExp) {
						seenDot = true;
						i++;
						continue;
					}
					if (ch == '.' && (seenDot || seenExp)) {
						invalidNumeric = true;
						break;
					}
					if ((ch == 'e' || ch == 'E') && !seenExp) {
						seenExp = true;
						i++;
						if (i < n && (line[i] == '+' || line[i] == '-')) i++;
						continue;
					}
					if ((ch == 'e' || ch == 'E') && seenExp) {
						invalidNumeric = true;
						break;
					}
					break;
				}

				if (invalidNumeric) {
					size_t j = i;
					while (j < n && !isBoundaryChar(line[j])) j++;
					string bad = line.substr(start, j - start);
					addError("Invalid numeric format", bad);
					i = j;
					continue;
				}

				if (seenExp && !expDigits) {
					string bad = line.substr(start, i - start);
					addError("Invalid numeric format", bad);
					continue;
				}

				if (i < n && isIdentifierChar(line[i])) {
					size_t j = i;
					while (j < n && isIdentifierChar(line[j])) j++;
					string bad = line.substr(start, j - start);
					addError("Invalid identifier", bad);
					i = j;
					continue;
				}

				string num = line.substr(start, i - start);
				tokenStream.push_back(num);
				if (seenDot || seenExp) {
					lineFloatConsts.push_back(num);
					typedStream.push_back({"FLOAT_CONST", num});
				} else {
					lineIntConsts.push_back(num);
					typedStream.push_back({"INT_CONST", num});
				}
				continue;
			}

			if (isPunct(c)) {
				addError("Unknown symbol", one);
				i++;
				continue;
			}

			if (!isStopChar(c)) {
				string unk(1, c);
				addError("Unknown symbol", unk);
			}
			i++;
		}

		cout << "Line: " << line << "\n";
		cout << "Token detected: " << joinQuotedCSV(tokenStream) << "\n";
		cout << "Findings : ----------------" << "\n";
		cout << "Keywords: " << joinTokens(lineKeywords) << "\n";
		cout << "Identifiers: " << joinTokens(lineIdentifiers) << "\n";
		cout << "Constants(Integer): " << joinTokens(lineIntConsts) << "\n";
		cout << "Constants(Float): " << joinTokens(lineFloatConsts) << "\n";
		cout << "Constants(String): " << joinTokens(lineStringConsts) << "\n";
		cout << "Constants(Character): " << joinTokens(lineCharConsts) << "\n";
		cout << "Operators(Arithmetic): " << joinTokens(lineOpArithmetic) << "\n";
		cout << "Operators(Relational): " << joinTokens(lineOpRelational) << "\n";
		cout << "Operators(Logical): " << joinTokens(lineOpLogical) << "\n";
		cout << "Operators(Bit-wise): " << joinTokens(lineOpBitwise) << "\n";
		cout << "Operators(Assignment): " << joinTokens(lineOpAssignment) << "\n";
		cout << "Operators(Inc/Dec): " << joinTokens(lineOpIncDec) << "\n";
		cout << "Delimiters: " << joinTokens(lineDelimiters) << "\n";
		cout << "Error Findings : ----------------" << "\n";
		cout << "Errors: " << joinTokens(lineErrors) << "\n";
		cout << "------------------------------------------" << "\n\n";
		cout << "Token Stream :\n";
		for (const auto& t : typedStream) {
			cout << "<  " << t.first << " , " << t.second << "  >\n";
		}
		cout << "----------------------------------------\n";
		cout << "----------------------------------------\n";
		cout << "----------------------------------------\n";

		totalKeywords += lineKeywords.size();
		totalIdentifiers += lineIdentifiers.size();
		totalIntConsts += lineIntConsts.size();
		totalFloatConsts += lineFloatConsts.size();
		totalStringConsts += lineStringConsts.size();
		totalCharConsts += lineCharConsts.size();
		totalOpArithmetic += lineOpArithmetic.size();
		totalOpRelational += lineOpRelational.size();
		totalOpLogical += lineOpLogical.size();
		totalOpBitwise += lineOpBitwise.size();
		totalOpAssignment += lineOpAssignment.size();
		totalOpIncDec += lineOpIncDec.size();
		totalDelimiters += lineDelimiters.size();

		for (const auto& k : lineKeywords) uniqueKeywordSet.insert(k);
		for (const auto& id : lineIdentifiers) uniqueIdentifierSet.insert(id);
	}

	size_t totalTokens =
		totalKeywords + totalIdentifiers +
		totalIntConsts + totalFloatConsts + totalStringConsts + totalCharConsts +
		totalOpArithmetic + totalOpRelational + totalOpLogical + totalOpBitwise +
		totalOpAssignment + totalOpIncDec +
		totalDelimiters;

	vector<string> uniqueKeywords(uniqueKeywordSet.begin(), uniqueKeywordSet.end());
	vector<string> uniqueIdentifiers(uniqueIdentifierSet.begin(), uniqueIdentifierSet.end());
	sort(uniqueKeywords.begin(), uniqueKeywords.end());
	sort(uniqueIdentifiers.begin(), uniqueIdentifiers.end());

	cout << "\n========== Summary ==========" << "\n";
	cout << "Total Keywords: " << totalKeywords << "\n";
	cout << "Total Identifiers: " << totalIdentifiers << "\n";
	cout << "Total Constants(Integer): " << totalIntConsts << "\n";
	cout << "Total Constants(Float): " << totalFloatConsts << "\n";
	cout << "Total Constants(String): " << totalStringConsts << "\n";
	cout << "Total Constants(Character): " << totalCharConsts << "\n";
	cout << "Total Operators(Arithmetic): " << totalOpArithmetic << "\n";
	cout << "Total Operators(Relational): " << totalOpRelational << "\n";
	cout << "Total Operators(Logical): " << totalOpLogical << "\n";
	cout << "Total Operators(Bit-wise): " << totalOpBitwise << "\n";
	cout << "Total Operators(Assignment): " << totalOpAssignment << "\n";
	cout << "Total Operators(Inc/Dec): " << totalOpIncDec << "\n";
	cout << "Total Delimiters: " << totalDelimiters << "\n";
	cout << "Total Tokens: " << totalTokens << "\n";

	cout << "Unique Keywords: " << joinTokens(uniqueKeywords) << "\n";
	cout << "Unique Identifiers: " << joinTokens(uniqueIdentifiers) << "\n";

	cout << "\n========== Error Summary ==========" << "\n";
	if (allErrors.empty()) {
		cout << "(none)\n";
	} else {
		for (const auto& e : allErrors) {
			cout << e << "\n";
		}
	}

	cout << "\n========== Comments ==========" << "\n";
	if (commentBlocks.empty()) {
		cout << "(none)\n";
	} else {
		for (const auto& c : commentBlocks) {
			cout << c << "\n";
			cout << "----------------------------------------\n";
		}
	}

	vector<string> symbolNames;
	symbolNames.reserve(identifierFreq.size());
	for (const auto& kv : identifierFreq) symbolNames.push_back(kv.first);
	sort(symbolNames.begin(), symbolNames.end());

	size_t maxIdentLen = 10;
	for (const auto& name : symbolNames) {
		if (name.size() > maxIdentLen) maxIdentLen = name.size();
	}

	cout << "\n========== Symbol Table ==========" << "\n";
	cout << left << setw(static_cast<int>(maxIdentLen) + 2) << "Identifier"
	     << setw(10) << "Count"
	     << "FirstLine" << "\n";
	cout << string(maxIdentLen + 2 + 10 + 9, '-') << "\n";
	for (const auto& name : symbolNames) {
		cout << left << setw(static_cast<int>(maxIdentLen) + 2) << name
		     << setw(10) << identifierFreq[name]
		     << identifierFirstLine[name] << "\n";
	}

	return 0;
}
