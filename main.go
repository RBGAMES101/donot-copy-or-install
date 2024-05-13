package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"syscall"

	"golang.org/x/sys/windows"
	"golang.org/x/sys/windows/registry"
)

func main() {
	if checkAdmin() {
		becomeAdmin()
	}

	k, _, err := registry.CreateKey(registry.CLASSES_ROOT, `sandpile.legacy`, registry.QUERY_VALUE|registry.SET_VALUE)
	if err != nil {
		panic(err)
	}
	if err := k.SetStringValue("URL Protocol", ""); err != nil {
		panic(err)
	}
	if err := k.Close(); err != nil {
		panic(err)
	}
	k2, _, err := registry.CreateKey(registry.CLASSES_ROOT, `sandpile.legacy\shell\open\command`, registry.QUERY_VALUE|registry.SET_VALUE)
	if err != nil {
		panic(err)
	}

	var programfiles string

	if !check32bit() {
		programfiles = `C:\\Program Files (x86)`
	} else {
		programfiles = `C:\\Program Files`
	}

	appdata, err := os.UserConfigDir()
	if err != nil {
		return
	}

	if err := k2.SetStringValue("", programfiles+`\SandPile\autoupdater.exe %1`); err != nil {
		panic(err)
	}
	if err := k2.Close(); err != nil {
		panic(err)
	}

	os.Mkdir(programfiles+`\SandPile`, 0644)
	os.Mkdir(appdata+`\SandPile`, 0644)
	out, err := os.Create(programfiles + `\SandPile\autoupdater.exe`)
	if err != nil {
		fmt.Println(err)
		return
	}
	defer out.Close()

	resp, err := http.Get("https://sandpile.xyz/static/autoupdater.exe")
	if err != nil {
		fmt.Println(err)
		return
	}
	defer resp.Body.Close()

	io.Copy(out, resp.Body)
}

func becomeAdmin() {
	verb := "runas"
	exe, _ := os.Executable()
	cwd, _ := os.Getwd()
	args := strings.Join(os.Args[1:], " ")

	verbPtr, _ := syscall.UTF16PtrFromString(verb)
	exePtr, _ := syscall.UTF16PtrFromString(exe)
	cwdPtr, _ := syscall.UTF16PtrFromString(cwd)
	argPtr, _ := syscall.UTF16PtrFromString(args)

	var showCmd int32 = 1 //SW_NORMAL

	err := windows.ShellExecute(0, verbPtr, exePtr, argPtr, cwdPtr, showCmd)
	if err != nil {
		fmt.Println(err)
	}
}

func checkAdmin() bool {
	_, err := os.Open("\\\\.\\PHYSICALDRIVE0")
	return err != nil
}

func check32bit() bool { //returns true if windows is 32bit
	_, err := os.Open(`C:\\Program Files (x86)`)
	return err != nil
}
