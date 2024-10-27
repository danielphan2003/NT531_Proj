import json
import sys

def parse_line(line):
    parts = line.strip().split()
    if len(parts) < 5:
        return None

    return {
        "total_requests": int(parts[2]),
        "successful_requests": int(parts[4]),
        "failed_requests": int(parts[6]),
    }

def main():
    log_data = []

    for line in sys.stdin:
        parsed_data = parse_line(line)
        if parsed_data: 
            log_data.append(parsed_data)

    print(json.dumps(log_data, indent=4))

if __name__ == "__main__":
    main()
