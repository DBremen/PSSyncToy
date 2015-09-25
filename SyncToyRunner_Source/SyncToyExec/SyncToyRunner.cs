using System;
using System.Collections.Generic;
using System.Collections;
using System.Text;
using System.Diagnostics;
using System.IO;
using System.Runtime.Serialization;

namespace SyncToyRunner
{
    class SyncToyRun
    {
        private Int32 PercentComplete = 0;
        private int numActions = 0;
        private static bool prevOnly;
        static void Main(string[] args)
        {
            string ConfigFileName = args[0];
            int index =  Convert.ToInt32(args[1]);
            prevOnly = Convert.ToBoolean(args[2]);

            if (ConfigFileName.Length > 0)
            {
                SyncToyRun app = new SyncToyRun();
                app.SyncFolderPairs(ConfigFileName,index,prevOnly);
            }  
        }

        
        public SyncToyRun()
        {
        }

       
        public void SyncFolderPairs(string ConfigFileName, int index, bool previewOnly)
        {
            SyncToy.SyncEngineConfig SEConfig = null;
            ArrayList EngineConfigs = new ArrayList();
            System.Runtime.Serialization.Formatters.Binary.BinaryFormatter bf = new System.Runtime.Serialization.Formatters.Binary.BinaryFormatter();
            try
            {
                using (StreamReader sr = new StreamReader(ConfigFileName))
                {
                    do
                    {
                        SEConfig = (SyncToy.SyncEngineConfig)bf.Deserialize(sr.BaseStream);
                        EngineConfigs.Add(SEConfig);
                    }
                    while (sr.BaseStream.Position < sr.BaseStream.Length);
                    sr.Close();
                }
                if (index != -1)
                {
                    SyncFolderPair((SyncToy.SyncEngineConfig)EngineConfigs[index], previewOnly);
                }
                else
                {
                    foreach (SyncToy.SyncEngineConfig Config in EngineConfigs)
                    {
                        SyncFolderPair(Config, previewOnly);
                    }
                }
           }
            catch (Exception ex)
            {
                Console.WriteLine("SyncFolderPairs Exception -> {0}", ex.Message);
            }
        }   

        private void SyncFolderPair(SyncToy.SyncEngineConfig Config, bool previewOnly)
        {
            PercentComplete = 0;
            try
            {
                SyncToy.SyncEngine Engine = new SyncToy.SyncEngine(Config);
                Engine.syncEvent += new SyncToy.SyncEventHandler(SyncEngineEventHandler);
                Engine.Preview();
                if (!previewOnly)
                {
                    Engine.Sync();
                }
                Engine = null;
            }
            catch (Exception ex)
            {
                Console.WriteLine("SyncFolderPair Exception -> {0}", ex.Message);
            }
        }   // SyncFolderPair
        public void SyncEngineEventHandler(object sender, SyncToy.SyncEventArgs SEArgs)
        {
            if (SEArgs.Failed)
            {
                string Msg = string.Format("Error: {0}", SEArgs.Action.ToErrorText());
                Console.WriteLine(Msg);
            }
            else if (SEArgs.Action != null && SEArgs.PreviewMode)
            {
                if (prevOnly)
                {
                    Console.WriteLine("{0},{1:N},{2},{3}", SEArgs.Action.Code,"", SEArgs.Action.SourceFullPath, SEArgs.Action.DestinationFullPath);
                }
                numActions++;
            }
            else if(SEArgs.Action != null && !SEArgs.PreviewMode)
            {
                PercentComplete++;
                Console.WriteLine("{0},{1:N},{2},{3}", SEArgs.Action.Code, (double)PercentComplete / numActions*100, SEArgs.Action.SourceFullPath, SEArgs.Action.DestinationFullPath);
            }
        }
    }
} 
