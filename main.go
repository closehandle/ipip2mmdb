package main

import (
	"bufio"
	"log"
	"net"
	"os"

	"github.com/maxmind/mmdbwriter"
	"github.com/maxmind/mmdbwriter/mmdbtype"
)

var (
	Record = mmdbtype.Map{
		"country": mmdbtype.Map{
			"geoname_id":           mmdbtype.Uint32(1814991),
			"is_in_european_union": mmdbtype.Bool(false),
			"iso_code":             mmdbtype.String("CN"),
			"names": mmdbtype.Map{
				"de":    mmdbtype.String("China"),
				"en":    mmdbtype.String("China"),
				"es":    mmdbtype.String("China"),
				"fr":    mmdbtype.String("Chine"),
				"ja":    mmdbtype.String("中国"),
				"pt-BR": mmdbtype.String("China"),
				"ru":    mmdbtype.String("Китай"),
				"zh-CN": mmdbtype.String("中国"),
			},
		},
	}
)

func main() {
	mmdb, err := mmdbwriter.New(
		mmdbwriter.Options{
			DatabaseType: "GeoIP2-Country",
			RecordSize:   24,
		},
	)
	if err != nil {
		log.Fatalf("fail to new writer %v\n", err)
	}

	{
		file, err := os.Open("ipv4.txt")
		if err != nil {
			log.Fatalf("fail to open %s\n", err)
		}

		data := make([]string, 0)
		scan := bufio.NewScanner(file)
		scan.Split(bufio.ScanLines)
		for scan.Scan() {
			data = append(data, scan.Text())
		}

		list := ParseCIDR(data)
		for _, addr := range list {
			err = mmdb.Insert(addr, Record)
			if err != nil {
				log.Fatalf("fail to insert to writer %v\n", err)
			}
		}
	}

	{
		file, err := os.Open("ipv6.txt")
		if err != nil {
			log.Fatalf("fail to open %s\n", err)
		}

		data := make([]string, 0)
		scan := bufio.NewScanner(file)
		scan.Split(bufio.ScanLines)
		for scan.Scan() {
			data = append(data, scan.Text())
		}

		list := ParseCIDR(data)
		for _, addr := range list {
			err = mmdb.Insert(addr, Record)
			if err != nil {
				log.Fatalf("fail to insert to writer %v\n", err)
			}
		}
	}

	file, err := os.Create("Country.mmdb")
	if err != nil {
		log.Fatalf("fail to create output file %v\n", err)
	}

	_, err = mmdb.WriteTo(file)
	if err != nil {
		log.Fatalf("fail to write to file %v\n", err)
	}
}

func ParseCIDR(strs []string) []*net.IPNet {
	list := make([]*net.IPNet, 0)

	for _, cidr := range strs {
		_, addr, err := net.ParseCIDR(cidr)
		if err != nil || addr == nil {
			log.Printf("%s fail to parse to CIDR\n", cidr)
			continue
		}

		list = append(list, addr)
	}

	return list
}
