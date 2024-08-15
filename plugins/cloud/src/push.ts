import { EventEmitter } from 'events';
import { PushReceiver } from '@eneris/push-receiver';
import { Deferred } from '@scrypted/common/src/deferred';
import type { Types } from '@eneris/push-receiver/dist/client';

export declare interface PushManager {
    on(event: 'message', listener: (data: any) => void): this;
    on(event: 'registrationId', listener: (registrationId: string) => void): this;
}

export class PushManager extends EventEmitter {
    registrationId: Promise<string>;

    constructor(public senderId: string) {
        super();

        this.registrationId = (async () => {
            let savedConfig: Partial<Types.ClientConfig>
            try {
                const savedConfigJson = localStorage.getItem('config');
                if (!savedConfigJson)
                    throw new Error();
                savedConfig = JSON.parse(savedConfigJson);
            }
            catch (e) {
                savedConfig = {};
            }

            const instance = new PushReceiver({
                ...savedConfig,
                firebase: {
                    messagingSenderId: senderId,
                    projectId: 'scrypted-app',
                    apiKey: 'AIzaSyDI0bgFuVPIqKZoNpB-iTOU7ijIeepxOXE',
                    appId: '1:827888101440:web:6ff9f8ada107e9cc0097a5',
                } ,
                heartbeatIntervalMs: 15 * 60 * 1000,
            });

            const deferred = new Deferred<string>();

            const saveConfig = () => {
                localStorage.setItem('config', JSON.stringify(savedConfig));
            }

            const stopListeningToCredentials = instance.onCredentialsChanged(({ oldCredentials, newCredentials }) => {
                savedConfig.credentials = newCredentials;
                deferred.resolve(newCredentials.fcm.token);
                this.registrationId = Promise.resolve(newCredentials.fcm.token);
                saveConfig();
                this.emit('registrationId', newCredentials.fcm.token);
            });

            const stopListeningToNotifications = instance.onNotification(({ message }) => {
                savedConfig.persistentIds = instance.persistentIds;
                saveConfig();
                this.emit('message', message.data);
            });

            await instance.connect();

            return savedConfig.credentials?.fcm?.token || deferred.promise;
        })();
    }
}
