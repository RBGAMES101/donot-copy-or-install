using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;
using HttpClientProgress;
using System.Security.Policy;
using System.Diagnostics;

namespace SandPileAutoupdater
{
    public partial class Form1 : Form
    {
        private readonly HttpClient httpClient = new HttpClient();

        public Form1()
        {
            InitializeComponent();
        }

        private async void Form1_Load(object sender, EventArgs e)
        {
            string appdata = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
            string[] args = Environment.GetCommandLineArgs();
            Uri url = new Uri(args.Last());

            await CheckForUpdate(appdata);

            label1.Text = "Launching player...";
            Process.Start(appdata + "/SandPile/Player.exe", url.AbsolutePath.Substring(1));

            Application.Exit();
        }

        private async Task CheckForUpdate(string appdata)
        {

            Directory.CreateDirectory(appdata + "/SandPile/");


            string latestVer = await httpClient.GetStringAsync("https://sandpile.xyz/api/GetClientVersion");

            string currentVer;
            try
            {
                currentVer = File.ReadAllText(appdata + "/SandPile/version");
            }
            catch (Exception)
            {
                currentVer = "0";
            }

            if (!File.Exists(appdata + "/SandPile/Player.exe") || currentVer != latestVer)
            {
                var progress = new Progress<float>();

                label1.Text = "Downloading update...";
                progressBar1.Style = ProgressBarStyle.Blocks;

                progress.ProgressChanged += Progress_ProgressChanged;

                using (var file = new FileStream(appdata + "/SandPile/Player.exe", FileMode.Create, FileAccess.Write, FileShare.None))
                    await httpClient.DownloadDataAsync("https://sandpile.xyz/static/Player.exe", file, progress);

                File.WriteAllText(appdata + "/SandPile/version", latestVer);

                progressBar1.Value = 0;
                progressBar1.Style = ProgressBarStyle.Marquee;
            }

        }

        void Progress_ProgressChanged(object sender, float progress)
        {
            progressBar1.Value = Math.Min((int)(progress * 100), 99);
        }

        private void pictureBox1_Click(object sender, EventArgs e)
        {

        }

        private void label1_Click(object sender, EventArgs e)
        {

        }
    }


}
