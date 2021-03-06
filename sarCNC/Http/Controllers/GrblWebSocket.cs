﻿/*
 * Created by SharpDevelop.
 * User: kboronka
 * Date: 7/7/2016
 * Time: 10:28 AM
 * 
 * To change this template use Tools | Options | Coding | Edit Standard Headers.
 */
using System;
using System.Collections.Generic;

using sar.Http;
using sar.Tools;

// https://github.com/grbl/grbl/wiki/Configuring-Grbl-v0.9

namespace sar.CNC.Http
{
	[SarWebSocketController]
	public class GrblWebSocket : HttpWebSocket
	{
		#region static
		
		private static List<HttpWebSocket> clients = new List<HttpWebSocket>();
		private static object clientListLock = new object();
		
		public static void Start()
		{
			lock (clientListLock)
			{
				clients = new List<HttpWebSocket>();
			}
			
			HttpWebSocket.ClientConnected += AddClient;
			HttpWebSocket.ClientDisconnected += DropClient;
		}
		
		public static void Stop()
		{
			HttpWebSocket.ClientConnected -= AddClient;
			HttpWebSocket.ClientDisconnected -= DropClient;
		}
		
		private static void AddClient(HttpWebSocket client)
		{
			if (client is GrblWebSocket)
			{
				Logger.Log("Client " + client.ID.ToString() + " Connected");
				lock (clientListLock)
				{
					try
					{
						clients.Add(client);
					}
					catch
					{
						
					}
				}
			}
		}
		
		private static void DropClient(HttpWebSocket client)
		{
			if (client is GrblWebSocket)
			{
				Logger.Log("Client " + client.ID.ToString() + " Disconnected");
				lock (clientListLock)
				{
					try
					{
						clients.RemoveAll(c => c.ID == client.ID);
					}
					catch
					{
						
					}
				}
			}
		}
		
		public static void SendToWebSocketClients(string raw)
		{
			lock (clientListLock)
			{
				try
				{
					foreach (var client in clients.ToArray())
					{
						if (client != null && client.Open)
						{
							client.SendString(raw);
						}
					}
				}
				catch
				{
					
				}
			}
		}
		
		#endregion

		public GrblWebSocket(HttpRequest request)
			: base(request)
		{
			// do nothing
		}
		
		override public void NewData(string rxBuffer)
		{
			var commands = rxBuffer.Split('\n');
			
			foreach (var command in commands)
			{
				Engine.Port.QueueCommand(command);
			}
		}
	}
}
